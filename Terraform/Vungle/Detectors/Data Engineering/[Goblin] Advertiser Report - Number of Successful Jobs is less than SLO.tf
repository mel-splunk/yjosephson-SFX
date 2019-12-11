# [Goblin] Advertiser Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "[Goblin] Advertiser Report - Number of Successful Jobs is less than SLO" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] Advertiser Report - Number of Successful Jobs is less than SLO"
  description = "## Description:\nBatch Pipeline which sync data from Cheezit advertiser_report table to Memsql advertiser_report tables and perform aggregations to generate advertiser_report_daily data. The advertiser_report_daily table is source of pacing used by platform. Delay of the data syncing may result in overspend. This alert is triggered when sync records very few, or the redshift2memsql job didn't run for 1 hour.\n\n## Data Source:\n**Data Source:** Cheezit advertiser_report table\n\n**Data Destination:**  Memsql advertiser_report tables \n\n## Pipeline Components:\n**Airflow :** http://airflow.dataeng.vungle.io/admin/airflow/tree?dag_id=malygos_and_goblin\n\n**Jenkins:** https://jenkins.vungle.io/view/dataeng/view/goblin/job/data_goblin_adv_report_redshift2memsql_prod/\n\n##  OnCall logging Sheet:  \nhttps://docs.google.com/spreadsheets/d/1fZXocJ8aaPRLWyl0_x3lAUn7-embQFyBIrbmCkJJ5QE/edit#gid=0\n\n\n{{#is_alert}} \n\n## Quick Fix Guidance: \n1. Log this incident into OnCall  logging Sheet.\n2. Check console output of the jenkins job\n3. If found any error, log this error into https://docs.google.com/presentation/d/1V9eMcUGannTTGJyIGO7S4wkB4Z62MTMRSl8OjavC5Go/edit?usp=sharing\n4. Page Data team according to \"DataEng Follow the sun\" \n5. Re-run the Jenkins job and you could find parameter from the build history(if any). \n6. If the problem could not be solved, page anyone who you think may help you on this issue.\n\n{{/is_alert}}\n @slack-dataeng-monitoring\n\n*What happened*\nGiven DataDog evaluation timeframe limitation (1, 5, 10, 15 and 30 minutes) and the maximum gap between 2 consecutive successful Goblin Advertiser Report that is more than 1 hour minutes, the sensitivity of this monitor will trigger a lot of false alarms.\n\nTo reduce the noise, an alert notification will only be sent if this monitor stays in alert state for more than 10 minutes.\n \n*Full runbook:*\n> https://vungle.atlassian.net/wiki/spaces/SRE/pages/866451770/Redshift+to+MemSQL\n\nMOTM SEED: https://app.datadoghq.com/monitors/10997829\n\n@pagerduty-Datadog @slack-dataeng-monitoring @slack-devops-oncall"

/*  query = <<EOQ
    sum(last_1m):max:custom_atf_data_goblin_adv_report_redshift2memsql_prod{*} >= 10
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.redshift2memsql.advertiser_report_daily.rows', rollup='max').sum(over='1m')
			
			detect(when(signal >= 10 )).publish('CRIT')

  EOF

	rule {
		description = "maximum >= 10 for last 1m"
		severity = "Critical"
	}

}

variable "clusters" {
    default = ["clusterA", "clusterB"]
}
