# [Goblin] Sync CPA Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "[Goblin] Sync CPA Report - Number of Successful Jobs is less than SLO" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] Sync CPA Report - Number of Successful Jobs is less than SLO"
  description = "Batch pipeline which transform data from Cheezit dynamic_campaign_installs table into data in Cheezit cpa_report table. The job runs once every hour."

/*  query = <<EOQ
    sum(last_1m):max:custom_atf_data_goblin_sync_cpa_report_succeeded{*} >= 10
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.update_redshift.update_cpa_report.success', rollup='max').sum(over='1m')
			
			detect(when(signal >= 10)).publish('CRIT')

  EOF

	rule {
		description = "Sum >= 10 for last 1m"
		severity = "Critical"
	}

}
