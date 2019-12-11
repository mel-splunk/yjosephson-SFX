# [P1][Malygos] advertiser_user_events.ingestion report count too low
resource "signalfx_detector" "[P1][Malygos] advertiser_user_events.ingestion report count too low" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] advertiser_user_events.ingestion report count too low"
  description = "Streaming pipeline which consumes data from Kafka in-eventDataInfo topic and performs insert into our Cheezit data warehouse for generating advertiser_user_events table."

/*  query = <<EOQ
    max(last_1h):avg:malygos.advertiser_user_events.ingestion.streaming.consumed.records{env:prod2} < 100000
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.advertiser_user_events.ingestion.streaming.consumed.records', filter=filter('environment', 'prod2'), rollup='average').max(over='1h')

			detect(when(signal < 100000)).publish('CRIT')

  EOF

	rule {
		description = "Max < 100000 for last 1h"
		severity = "Critical"
	}

}
