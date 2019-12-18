# Meister Processing Filters
resource "signalfx_detector" "meister_processing_filters" {
	name = "Meister Processing Filters"
	description = "Processing Filters is Taking Too Long"

	program_text = <<-EOF
		signal = data('dsp.meister.filter.duration.all.95percentile', filter=filter('environment', 'api-gke'), rollup='average').min(over='5m')
		detect(when(signal >= 1000)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Min >= 1000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
