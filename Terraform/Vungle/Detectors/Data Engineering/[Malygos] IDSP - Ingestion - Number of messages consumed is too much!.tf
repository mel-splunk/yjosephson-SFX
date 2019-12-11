# [Malygos] IDSP - Ingestion - Number of messages consumed is too much!
resource "signalfx_detector" "[Malygos] IDSP - Ingestion - Number of messages consumed is too much!" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] IDSP - Ingestion - Number of messages consumed is too much!"
  description = "The last IDSP Ingestion batch consumed too much messages"

/*  query = <<EOQ
    min(last_1h):avg:malygos.idsp.ingestion.streaming.consumed.records{env:prod} >= 25000000
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.idsp.ingestion.streaming.consumed.records', filter=filter('environment', 'prod')).min(over='1h')
      
			detect(when(signal >= 25000000)).publish('CRIT')

  EOF

	rule {
		description = "Min >= 25000000 for last 1h"
		severity = "Critical"
	}

}
