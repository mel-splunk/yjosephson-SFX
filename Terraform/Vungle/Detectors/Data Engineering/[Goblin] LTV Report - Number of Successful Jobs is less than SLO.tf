# [Goblin] LTV Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "goblin_ltv_report_number_of_successful_jobs_is_less_than_slo" {
	name = "[Goblin] LTV Report - Number of Successful Jobs is less than SLO"
	description = "Monitor the times for ltv report running which calculate and load data from cheezit to memsql, and then ingest into memsql ltv_report_daily"

	program_text = <<-EOF
		signal = data('goblin.ltv_report.count', rollup='max').sum(over='1m')
		detect(when(signal >= 60 )).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum >= 60 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
