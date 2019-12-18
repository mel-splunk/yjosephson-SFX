# Meister Too many datasci errors
resource "signalfx_detector" "meister_too_many_datasci_errors" {
	name = "Meister Too many datasci errors"
	description = "The number of datasci errors is problematic"

	program_text = <<-EOF
		A = data('dsp.meister.datasci.request.succeed', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		B = data('dsp.meister.datasci.request.since_start', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		signal = (A/B).scale(100).mean(over='5m')
		detect(when(signal < 80)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average < 80 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
