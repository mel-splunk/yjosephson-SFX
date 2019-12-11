# [P0][Malygos] runtime.version is invalid
resource "signalfx_detector" "[P0][Malygos] runtime.version is invalid" {
  count = "${length(var.clusters)}"
  name    = "[P0][Malygos] runtime.version is invalid"
  description = "Monitor the online version of Malygos, this alert is triggered when the deployed version is smaller than the expected version"

/*  query = <<EOQ
    min(last_10m):min:malygos.runtime.version{env:prod} < 1109
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.runtime.version', filter=filter('environment', 'prod'), rollup='min').min(over='10m')

			detect(when(signal < 1109)).publish('CRIT')

  EOF

	rule {
		description = "Min < 1109 for last 10m"
		severity = "Critical"
	}

}
