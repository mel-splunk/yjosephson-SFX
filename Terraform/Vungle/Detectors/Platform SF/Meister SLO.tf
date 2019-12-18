# Meister SLO
resource "signalfx_detector" "meister_slo" {
	name = "Meister SLO"
	description = "Response Time is Taking Too Long"

	program_text = <<-EOF
		signal = data('dsp.meister.endpoint.api.v1.time.95percentile', filter=filter('environment', 'api-gke'), rollup='average').mean(over='10m')
		detect(when(signal >= 2000)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average >= 2000 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
