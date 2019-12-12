# [P0][Malygos] runtime.version is invalid
resource "signalfx_detector" "p0_malygos_runtime_version_is_invalid" {
	count = "1"
	name = "[P0][Malygos] runtime.version is invalid"
	description = "Monitor the online version of Malygos, this alert is triggered when the deployed version is smaller than the expected version"

	program_text = <<-EOF
		signal = data('malygos.runtime.version', filter=filter('environment', 'prod'), rollup='min').min(over='10m')
		detect(when(signal < 1109)).publish('CRIT')
	EOF

	rule {
		description = "Min < 1109 for last 10m"
		severity = "Critical"
		detect_label = "Processing messages last 10m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
