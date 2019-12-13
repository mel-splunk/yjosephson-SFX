# [Goblin] EDSP Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "goblin_edsp_report_number_of_successful_jobs_is_less_than_slo" {
	name = "[Goblin] EDSP Report - Number of Successful Jobs is less than SLO"
	description = "Batch pipeline which sync data from Cheezit edsp_report table to Memsql edsp_report_column table"

	program_text = <<-EOF
		signal = data('goblin.redshift2memsql.edsp_report_column.rows', filter=filter('environment', 'prod'), rollup='max').sum(over='1m')
		detect(when(signal >= 10)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum >= 10 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
