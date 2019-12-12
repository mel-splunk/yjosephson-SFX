# [Goblin] Sync CPA Report - Number of Successful Jobs is less than SLO
resource "signalfx_detector" "goblin_sync_cpa_report_number_of_successful_jobs_is_less_than_slo" {
	count = "1"
	name = "[Goblin] Sync CPA Report - Number of Successful Jobs is less than SLO"
	description = "Batch pipeline which transform data from Cheezit dynamic_campaign_installs table into data in Cheezit cpa_report table. The job runs once every hour."

	program_text = <<-EOF
		signal = data('goblin.update_redshift.update_cpa_report.success', rollup='max').sum(over='1m')
		detect(when(signal >= 10)).publish('CRIT')
	EOF

	rule {
		description = "Sum >= 10 for last 1m"
		severity = "Critical"
		detect_label = "Processing messages last 1m"
    notifications = ["Email,foo-alerts@bar.com"]
	}

}
