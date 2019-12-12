# [P1][Malygos] advertiser_user_events.ingestion report count too low
resource "signalfx_detector" "p1_malygos_advertiser_user_events_ingestion_report_count_too_low" {
	count = "1"
	name = "[P1][Malygos] advertiser_user_events.ingestion report count too low"
	description = "Streaming pipeline which consumes data from Kafka in-eventDataInfo topic and performs insert into our Cheezit data warehouse for generating advertiser_user_events table."

	program_text = <<-EOF
		signal = data('malygos.advertiser_user_events.ingestion.streaming.consumed.records', filter=filter('environment', 'prod2'), rollup='average').max(over='1h')
		detect(when(signal < 100000)).publish('CRIT')
	EOF

	rule {
		description = "Max < 100000 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 30m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
