# [P1][Malygos] install_postback.ingestion failed to run in 30 minutes
resource "signalfx_detector" "[P1][Malygos] install_postback.ingestion failed to run in 30 minutes" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] install_postback.ingestion failed to run in 30 minutes"
  description = "Streaming pipeline which loads data from install_postback topic and perform etl on them and insert into cheezit install_postback table."

/*  query = <<EOQ
    sum(last_30m):avg:malygos.install_postback.ingestion.success{env:prod} < 1
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.install_postback.ingestion.success', filter=filter('environment', 'prod'), rollup='average').sum(over='30m')

			detect(when(signal < 1)).publish('CRIT')

  EOF

	rule {
		description = "Sum < 1 for last 30m"
		severity = "Critical"
	}

}
