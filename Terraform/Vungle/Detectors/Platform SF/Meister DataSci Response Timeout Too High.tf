# Meister DataSci Response Timeout Too High
resource "signalfx_detector" "meisterdatasci_response_timeout_too_high" {
	name = "Meister DataSci Response Timeout Too High"
	description = "DataSci connection timeout is too high"

	program_text = <<-EOF
		A = data('dsp.meister.datasci.request.timeout', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		B = data('dsp.meister.datasci.request.error.http_request_connection', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		C = data('dsp.meister.datasci.request.succeed', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		signal = ((A+B) / (A+B+C)).scale(100).mean(over='10m')
		detect(when(signal >= 10)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average >= 10 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
