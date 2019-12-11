# [Malygos] IDSP - Ingestion - Scheduling Delay is Larger than Usual
resource "signalfx_detector" "[Malygos] IDSP - Ingestion - Scheduling Delay is Larger than Usual" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] IDSP - Ingestion - Scheduling Delay is Larger than Usual"
  description = "Scheduling delay in Malygos IDSP Ingestion streaming job is larger than usual"

/*  query = <<EOQ
    min(last_1h):avg:malygos.idsp.ingestion.streaming.scheduling.delay.in.seconds{env:prod} / 60 > 10
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.idsp.ingestion.streaming.scheduling.delay.in.seconds', filter=filter('environment', 'prod')).min(over='1h') / 60

			detect(when(signal > 10)).publish('CRIT')

  EOF

	rule {
		description = "Min > 10 for last 1b"
		severity = "Critical"
	}

}
