# Meister DataSci Response Error Too High
resource "signalfx_detector" "meister_datasci_response_error_too_high" {
	name = "Meister DataSci Response Error Too High"
	description = "DataSci Response status NOT OK is too high"

	program_text = <<-EOF
		A = data('dsp.meister.datasci.response.not_status_ok', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		B = data('dsp.meister.datasci.request.succeed', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		signal = (A/(A+B)).scale(100).sum(over='5m')
		detect(when(signal >= 10)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum >= 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
