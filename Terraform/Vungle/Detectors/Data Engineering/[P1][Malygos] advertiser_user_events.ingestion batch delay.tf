# [P1][Malygos] advertiser_user_events.ingestion batch delay
resource "signalfx_detector" "p1_malygos_advertiser_user_events_ingestion_batch_delay" {
	count = "1"
	name = "[P1][Malygos] advertiser_user_events.ingestion batch delay"
	description = "Streaming pipeline which consumes data from Kafka in-eventDataInfo topic and performs insert into our Cheezit data warehouse for generating advertiser_user_events table."

	program_text = <<-EOF
		signal = data('malygos.advertiser_user_events.ingestion.streaming.total.delay.in.seconds', rollup='average').max(over='1h')
		detect(when(signal > 2700)).publish('CRIT')
	EOF

	rule {
		description = "Max > 2700 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
