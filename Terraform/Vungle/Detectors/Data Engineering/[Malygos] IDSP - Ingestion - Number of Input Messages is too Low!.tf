# [Malygos] IDSP - Ingestion - Number of Input Messages is too Low!
resource "signalfx_detector" "malygos_idsp_ingestion_number_of_input_messages_is_too_low" {
	count = "1"
	name = "[Malygos] IDSP - Ingestion - Number of Input Messages is too Low!"
	description = "Number of messages ingested much lower than normal."

	program_text = <<-EOF
		signal = data('malygos.idsp.ingestion.streaming.consumed.records', filter=filter('environment', 'prod'), rollup='average').max(over='1h')
		detect(when(signal < 1000000)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1000000 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
