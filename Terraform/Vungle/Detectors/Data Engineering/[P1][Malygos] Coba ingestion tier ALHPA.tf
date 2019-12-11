# [P1][Malygos] Coba ingestion tier ALHPA
resource "signalfx_detector" "[P1][Malygos] Coba ingestion tier ALHPA" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] Coba ingestion tier ALHPA"
  description = "Streaming pipeline which consumes data from Kafka topic and save it in AWS S3 by ingest time, for OLAP system usage. This alert is triggered when the streaming batch delayed or the as-install Postbacks count low."

/*  query = <<EOQ
    avg(last_15m):avg:malygos.coba.ingestion.output.as_installPostbacks.count{env:prod} < 10000
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.coba.ingestion.output.as-installPostbacks.count', filter=filter('environment', 'prod'), rollup='average').mean(over='15m')

			detect(when(signal < 10000)).publish('CRIT')

  EOF

	rule {
		description = "Average < 10000 for last 15m"
		severity = "Critical"
	}

}
