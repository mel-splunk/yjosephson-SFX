# [WIP][P2][Goblin] hbs redshift2memsql failed
resource "signalfx_detector" "wip_p2_goblin_hbs_redshift2memsql_failed" {
	count = "1"
	name = "[WIP][P2][Goblin] hbs redshift2memsql failed"
	description = "Batch pipeline which move data from Cheezit hbs_report_daily table to Memsql hbs_report_daily table."

	program_text = <<-EOF
		signal = data('goblin.redshift2memsql.hbs_report_daily.rows', filter=filter('environment', 'prod'), rollup='min').max(over='1d')
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	rule {
		description = "Max <= 0 for last 1d"
		severity = "Critical"
		detect_label = "Processing messages last 1d"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
