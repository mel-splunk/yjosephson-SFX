# [P1][Goblin] Sync and update no fill requests to memsql prod: No data monitor
resource "signalfx_detector" "[P1][Goblin] Sync and update no fill requests to memsql prod: No data monitor" {
  count = "${length(var.clusters)}"
  name    = "[P1][Goblin] Sync and update no fill requests to memsql prod: No data monitor"
  description = "Batch pipeline which move data from Cheezit publisher_report table then transform it and insert into Memsql publisher_requests_report_column table. The memsql table is used for calculating fill rate for placements."

/*  query = <<EOQ
    avg(last_1d):avg:goblin.prod.redshift2memsql.publisher_requests_report_daily.rows{*} < 500
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.redshift2memsql.publisher_requests_report_daily.rows', rollup='average').mean(over='1d')

			detect(when(signal < 500)).publish('CRIT')

  EOF

	rule {
		description = "Average < 500 for last 1d"
		severity = "Critical"
	}

}
