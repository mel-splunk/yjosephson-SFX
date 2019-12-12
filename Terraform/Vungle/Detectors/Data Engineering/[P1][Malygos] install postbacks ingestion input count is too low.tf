# [P1][Malygos] install postbacks ingestion input count is too low
resource "signalfx_detector" "p1_malygos_install_postbacks_ingestion_input_count_is_too_low" {
	count = "1"
	name = "[P1][Malygos] install postbacks ingestion input count is too low"
	description = "Streaming pipeline which loads data from install_postback topic and performs ETL on them and inserts into Cheezit install_postback table. This alert is triggered when the ingested count is lower than the threshold we set."

	program_text = <<-EOF
		signal = data('malygos.install_postback.ingestion.input.count', filter=filter('environment', 'prod'), rollup='average').max(over='1d')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 1d"
		severity = "Critical"
		detect_label = "Processing messages last 1d"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
