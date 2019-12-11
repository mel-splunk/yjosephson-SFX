# [P1][Malygos] Coba ingestion tier BETA
resource "signalfx_detector" "[P1][Malygos] Coba ingestion tier BETA" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] Coba ingestion tier BETA"
  description = "Streaming pipeline which consumes data from Kafka topic and save it in AWS S3 by ingest time, for OLAP system usage. This alert is triggered when the streaming batch delayed or the ex-jaeger-transaction count low."

/*  query = <<EOQ
    avg(last_15m):avg:malygos.coba.ingestion.output.in_eventDataInfo.count{tier:beta,env:prod} < 100000
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.coba.ingestion.output.in-eventDataInfo.count', filter=filter('environment', 'prod') and filter('tier', 'beta'), rollup='average').mean(over='15m')

			detect(when(signal < 100000)).publish('CRIT')

  EOF

	rule {
		description = "Average < 100000 for last 15m"
		severity = "Critical"
	}

}
