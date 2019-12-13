# Nostradamus FFM model age  40 hours
resource "signalfx_detector" "nostradamus_ffm_model_age_40_hours" {
	name = "Nostradamus FFM model age  40 hours"
	description = "Nostradamus FFM model age  40 hours"

	program_text = <<-EOF
		signal = data('nostradamus.api_server.model_age', filter=filter('deployment', 'prod') and filter('version', '4.94.0'), rollup='average').mean(by=['model_name', 'version']).mean(over='5m') / 3600
		detect(when(signal > 40)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average > 40 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
