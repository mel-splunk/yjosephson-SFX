# [Tarva] PD Sparkle Install - Output message to Kafka is too low
resource "signalfx_detector" "tarva_pd_sparkle_install_output_message_to_kafka_is_too_low" {
	count = "1"
	name = "[Tarva] PD Sparkle Install - Output message to Kafka is too low"
	description = "Tarva jobs in last 1 hour produced messages to Kafka. This is much lower than normal."

	program_text = <<-EOF
		signal = data('tarva.output_to_kafka.pd-sparkle-installs.count', filter=filter('environment', 'prod'), rollup='max').max(over='1h')
		detect(when(signal < 2000)).publish('CRIT')
	EOF

	rule {
		description = "Max < 2000 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
