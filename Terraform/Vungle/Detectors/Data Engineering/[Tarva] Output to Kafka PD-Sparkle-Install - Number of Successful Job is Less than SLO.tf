# [Tarva] Output to Kafka PD-Sparkle-Install - Number of Successful Job is Less than SLO
resource "signalfx_detector" "tarva_output_to_kafka_pd_sparkle_install_number_of_successful_job_is_less_than_slo" {
	count = "1"
	name = "[Tarva] Output to Kafka PD-Sparkle-Install - Number of Successful Job is Less than SLO"
	description = "Number of successful job run is less than SLO. According to SLO, Tarva (Output to Kafka PD-Sparkle-Installs) usually runs 2x per hour."

	program_text = <<-EOF
		signal = data('tarva.output_to_kafka.pd-sparkle-installs.success', rollup='max').max(over='5m') + 30
		detect(when(signal > 40)).publish('CRIT')
	EOF

	rule {
		description = "Max > 40 for last 5m"
		severity = "Critical"
		detect_label = "Processing messages last 5m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
