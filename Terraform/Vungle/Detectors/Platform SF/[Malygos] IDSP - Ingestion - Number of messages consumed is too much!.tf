# [Malygos] IDSP - Ingestion - Number of messages consumed is too much!
resource "signalfx_detector" "malygos_idsp_ingestion_number_of_messages_consumed_is_too_much" {
	name = "[Malygos] IDSP - Ingestion - Number of messages consumed is too much!"
	description = "The last IDSP Ingestion batch consumed too much messages"

	program_text = <<-EOF
		signal = data('malygos.idsp.ingestion.streaming.consumed.records', filter=filter('environment', 'prod'), rollup='average').max(over='1h')
		detect(when(signal >= 25000000)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max >= 25000000 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
