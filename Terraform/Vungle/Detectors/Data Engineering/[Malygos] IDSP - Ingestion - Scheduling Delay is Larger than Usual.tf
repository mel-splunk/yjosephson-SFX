# [Malygos] IDSP - Ingestion - Scheduling Delay is Larger than Usual
resource "signalfx_detector" "malygos_idsp_ingestion_scheduling_delay_is_larger_than_usual" {
	count = "1"
	name = "[Malygos] IDSP - Ingestion - Scheduling Delay is Larger than Usual"
	description = "Scheduling delay in Malygos IDSP Ingestion streaming job is larger than usual"

	program_text = <<-EOF
		signal = data('malygos.idsp.ingestion.streaming.scheduling.delay.in.seconds', filter=filter('environment', 'prod'), rollup='average').min(over='1h') / 60
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Min > 10 for last 1b"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
