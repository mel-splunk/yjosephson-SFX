# [P1][Malygos] advertiser_user_events.ingestion batch delay
resource "signalfx_detector" "[P1][Malygos] advertiser_user_events.ingestion batch delay" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] advertiser_user_events.ingestion batch delay"
  description = "Streaming pipeline which consumes data from Kafka in-eventDataInfo topic and performs insert into our Cheezit data warehouse for generating advertiser_user_events table."

/*  query = <<EOQ
    max(last_1h):avg:malygos.advertiser_user_events.ingestion.streaming.total.delay.in.seconds{env:prod2} > 2700
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.advertiser_user_events.ingestion.streaming.total.delay.in.seconds', rollup='average').max(over='1h')

			detect(when(signal > 2700)).publish('CRIT')

  EOF

	rule {
		description = "Max > 2700 for last 1h"
		severity = "Critical"
	}

}
