# [P1][Malygos] Coba ingestion tier BETA
resource "signalfx_detector" "p1_malygos_coba_ingestion_tier_beta" {
	count = "1"
	name = "[P1][Malygos] Coba ingestion tier BETA"
	description = "Streaming pipeline which consumes data from Kafka topic and save it in AWS S3 by ingest time, for OLAP system usage. This alert is triggered when the streaming batch delayed or the ex-jaeger-transaction count low."

	program_text = <<-EOF
		signal = data('malygos.coba.ingestion.output.in-eventDataInfo.count', filter=filter('environment', 'prod') and filter('tier', 'beta'), rollup='average').mean(over='15m')
		detect(when(signal < 100000)).publish('CRIT')
	EOF

	rule {
		description = "Average < 100000 for last 15m"
		severity = "Critical"
		detect_label = "Processing messages last 15m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
