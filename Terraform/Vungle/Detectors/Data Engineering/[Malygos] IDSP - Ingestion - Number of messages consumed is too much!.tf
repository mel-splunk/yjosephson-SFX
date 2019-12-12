# [Malygos] IDSP - Ingestion - Number of messages consumed is too much!
resource "signalfx_detector" "malygos_idsp_ingestion_number_of_messages_consumed_is_too_much" {
	count = "1"
	name = "[Malygos] IDSP - Ingestion - Number of messages consumed is too much!"
	description = "The last IDSP Ingestion batch consumed too much messages"

	program_text = <<-EOF
		signal = data('malygos.idsp.ingestion.streaming.consumed.records', filter=filter('environment', 'prod'), rollup='average').min(over='1h')
		detect(when(signal >= 25000000)).publish('CRIT')
	EOF

	rule {
		description = "Min >= 25000000 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
