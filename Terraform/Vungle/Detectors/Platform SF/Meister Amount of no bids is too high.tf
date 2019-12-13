# Meister Amount of no bids is too high
resource "signalfx_detector" "meister_amount_of_no_bids_is_too_high" {
	name = "[Meister Amount of no bids is too high"
	description = "We are returning too many no bids"

	program_text = <<-EOF
		A = data('dsp.meister.response.api.v1.status.204', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		B = data('dsp.meister.response.api.v1.status.200', filter=filter('environment', 'api-gke'), rollup='rate').sum()
		signal = (A/(A+B)).scale(100).min(over='10m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Min > 90 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
