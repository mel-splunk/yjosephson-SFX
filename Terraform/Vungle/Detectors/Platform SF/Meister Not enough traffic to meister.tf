# Meister Not enough traffic to meister
resource "signalfx_detector" "meister_not_enough_traffic_to_meister" {
	name = "Meister Not enough traffic to meister"
	description = "Investigate the lack of traffic to meister"

	program_text = <<-EOF
		signal = data('dsp.meister.endpoint.api.v1.start', filter=filter('environment', 'api-gke'), rollup='rate').sum().mean(over='5m')
		detect(when(signal <= 20)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average <= 20 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
