# [P1][Malygos] Coba ingestion tier NIU
resource "signalfx_detector" "[P1][Malygos] Coba ingestion tier NIU" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] Coba ingestion tier NIU"
  description = "Streaming pipeline which consumes data from Kafka topic and save it in AWS S3 by ingest time, for OLAP system usage. This alert is triggered when the streaming batch delayed or the ex-jaeger-transaction count low."

/*  query = <<EOQ
    avg(last_15m):avg:malygos.coba.ingestion.output.ex_jaeger_transaction.count{env:prod,tier:niu} < 500000
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.coba.ingestion.output.ex-jaeger-transaction.count', filter=filter('environment', 'prod') and filter('tier', 'niu'), rollup='average').mean(over='15m')

			detect(when(signal < 500000)).publish('CRIT')

  EOF

	rule {
		description = "Average < 500000 for last 15m"
		severity = "Critical"
	}

}
