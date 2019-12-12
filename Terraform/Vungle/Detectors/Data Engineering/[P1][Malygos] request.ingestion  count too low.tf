# [P1][Malygos] request.ingestion  count too low
resource "signalfx_detector" "p1_malygos_request_ingestion_count_too_low" {
	count = "1"
	name = "[P1][Malygos] request.ingestion  count too low"
	description = "Streaming pipeline which loads data from Kafka ex-jaeger-transaction topic and perform etl on them and insert into cheezit requests_no_fill table."

	program_text = <<-EOF
		signal = data('malygos.request.ingestion.output.requests_no_fill.count', filter=filter('environment', 'prod'), rollup='average').max(over='1h')
		detect(when(signal < 1000000)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1000000 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
