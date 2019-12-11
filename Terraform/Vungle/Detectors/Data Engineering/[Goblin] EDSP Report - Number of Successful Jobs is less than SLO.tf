# [Goblin] EDSP Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "[Goblin] EDSP Report - Number of Successful Jobs is less than SLO" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] EDSP Report - Number of Successful Jobs is less than SLO"
  description = "## Description:\nA batch pipeline which sync data from Cheezit edsp_report table to Memsql edsp_report_column table. The table is used for Medivh queries. This alert is triggered when synced records count less than the threshold, or the job didn't run for 2 hours."

/*  query = <<EOQ
    sum(last_1m):max:custom_atf_data_goblin_edsp_report_redshift2memsql_prod{*} >= 10
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.redshift2memsql.edsp_report_column.rows', rollup='max').sum(over='1m')
			
			detect(when(signal >= 10 )).publish('CRIT')

  EOF

	rule {
		description = "maximum >= 10 for last 1m"
		severity = "Critical"
	}

}
