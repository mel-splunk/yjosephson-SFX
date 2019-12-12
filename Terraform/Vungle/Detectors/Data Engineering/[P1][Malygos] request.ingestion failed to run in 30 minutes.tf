# [P1][Malygos] request.ingestion failed to run in 30 minutes
resource "signalfx_detector" "p1_malygos_request_ingestion_failed_to_run_in_30_minutes" {
	count = "1"
	name = "[P1][Malygos] request.ingestion failed to run in 30 minutes"
	description = "Streaming pipeline which loads data from Kafka ex-jaeger-transaction topic and perform etl on them and insert into cheezit requests_no_fill table."

	program_text = <<-EOF
		signal = data('malygos.request.ingestion.success', filter=filter('environment', 'prod'), rollup='average').sum(over='30m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 30m"
		severity = "Critical"
		detect_label = "Processing messages last 30m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
