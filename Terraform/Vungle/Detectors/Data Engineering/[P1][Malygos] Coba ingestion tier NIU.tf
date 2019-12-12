# [P1][Malygos] Coba ingestion tier NIU
resource "signalfx_detector" "p1_malygos_coba_ingestion_tier_niu" {
	count = "1"
	name = "[P1][Malygos] Coba ingestion tier NIU"
	description = "Streaming pipeline which consumes data from Kafka topic and save it in AWS S3 by ingest time, for OLAP system usage. This alert is triggered when the streaming batch delayed or the ex-jaeger-transaction count low."

	program_text = <<-EOF
		signal = data('malygos.coba.ingestion.output.ex-jaeger-transaction.count', filter=filter('environment', 'prod') and filter('tier', 'niu'), rollup='average').mean(over='15m')
		detect(when(signal < 500000)).publish('CRIT')
	EOF

	rule {
		description = "Average < 500000 for last 15m"
		severity = "Critical"
		detect_label = "Processing messages last 15m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
