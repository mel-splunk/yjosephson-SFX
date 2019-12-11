# [Goblin] Publisher Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "[Goblin] Publisher Report - Number of Successful Jobs is less than SLO" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] Publisher Report - Number of Successful Jobs is less than SLO"
  description = "Batch pipeline which sync data from Cheezit publisher_report table to Memsql publisher_report table. The job runs more than 3 times every hour. The table is used for Medivh. This alert is triggered when the synced record count less than threshold."

/*  query = <<EOQ
    sum(last_1m):max:custom_atf_data_goblin_pub_report_redshift2memsql_prod{*} >= 10
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.redshift2memsql.publisher_report_daily.rows', rollup='max').sum(over='1m')
			
			detect(when(signal >= 10)).publish('CRIT')

  EOF

	rule {
		description = "Count >= 10 for last 1m"
		severity = "Critical"
	}

}
