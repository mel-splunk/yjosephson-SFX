# [P1][Malygos] advertiser_user_events.ingestion failed to run in last 30 minutes
resource "signalfx_detector" "p1_malygos_advertiser_user_events_ingestion_failed_to_run_in_last_30_minutes" {
	count = "1"
	name = "[P1][Malygos] advertiser_user_events.ingestion failed to run in last 30 minutes"
	description = "Streaming pipeline which consumes data from Kafka in-eventDataInfo topic and performs insert into our Cheezit data warehouse for generating advertiser_user_events table."

	program_text = <<-EOF
		signal = data('malygos.advertiser_user_events.ingestion.success', filter=filter('environment', 'prod2'), rollup='average').sum(over='30m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum < 1 for last 30m"
		severity = "Critical"
		detect_label = "Processing messages last 30m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
