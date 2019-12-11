# [Goblin] LTV Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "[Goblin] LTV Report - Number of Successful Jobs is less than SLO" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] LTV Report - Number of Successful Jobs is less than SLO"
  description = "## Description:\nMonitor the times for ltv report running which calculate and load data from cheezit to memsql, and then ingest into memsql ltv_report_daily"

/*  query = <<EOQ
    sum(last_1m):max:custom_atf_data_goblin_calc_ltv_report_prod{*} >= 60
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.ltv_report.count', rollup='max').sum(over='1m')
			
			detect(when(signal >= 60 )).publish('CRIT')

  EOF

	rule {
		description = "maximum >= 60 for last 1m"
		severity = "Critical"
	}

}
