# [Malygos] IDSP - Ingestion - Number of Input Messages is too Low!
resource "signalfx_detector" "[Malygos] IDSP - Ingestion - Number of Input Messages is too Low!" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] IDSP - Ingestion - Number of Input Messages is too Low!"
  description = "Number of messages ingested much lower than normal."

/*  query = <<EOQ
    max(last_1h):avg:malygos.idsp.ingestion.streaming.consumed.records{env:prod} < 1000000
  EOQ*/

  program_text = <<-EOF
    /* can't find matching metrics */
      signal = data('malygos.idsp.ingestion.streaming.consumed.records', filter=filter('environment', 'prod')).max(over='1h')
      
			detect(when(signal < 1000000)).publish('CRIT')

  EOF

	rule {
		description = "Max < 1000000 for last 1h"
		severity = "Critical"
	}

}
