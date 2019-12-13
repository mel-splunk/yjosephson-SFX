# [Goblin] Advertiser Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "goblin_advertiser_report_number_of_successful_jobs_is_less_than_slo" {
	name = "[Goblin] Advertiser Report - Number of Successful Jobs is less than SLO"
	description = "Batch Pipeline which sync data from Cheezit advertiser_report table to Memsql advertiser_report tables and perform aggregations to generate advertiser_report_daily data."

	program_text = <<-EOF
		signal = data('goblin.redshift2memsql.advertiser_report_daily.rows', rollup='max').sum(over='1m')
		detect(when(signal >= 10 )).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "maximum >= 10 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
