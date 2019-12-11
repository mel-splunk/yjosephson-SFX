# [Goblin] Advertiser Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "[Goblin] Advertiser Report - Number of Successful Jobs is less than SLO" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] Advertiser Report - Number of Successful Jobs is less than SLO"
  description = "## Description:\nBatch Pipeline which sync data from Cheezit advertiser_report table to Memsql advertiser_report tables and perform aggregations to generate advertiser_report_daily data. The advertiser_report_daily table is source of pacing used by platform. Delay of the data syncing may result in overspend. This alert is triggered when sync records very few, or the redshift2memsql job didn't run for 1 hour."

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
