# [P1][Malygos] advertiser_user_events.ingestion failed to run in last 30 minutes
resource "signalfx_detector" "[P1][Malygos] advertiser_user_events.ingestion failed to run in last 30 minutes" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] advertiser_user_events.ingestion failed to run in last 30 minutes"
  description = "Streaming pipeline which consumes data from Kafka in-eventDataInfo topic and performs insert into our Cheezit data warehouse for generating advertiser_user_events table."

/*  query = <<EOQ
    sum(last_30m):avg:malygos.advertiser_user_events.ingestion.success{env:prod2} < 1
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.advertiser_user_events.ingestion.success', filter=filter('environment', 'prod2'), rollup='average').sum(over='30m')

			detect(when(signal < 1)).publish('CRIT')

  EOF

	rule {
		description = "Sum < 1 for last 30m"
		severity = "Critical"
	}

}
