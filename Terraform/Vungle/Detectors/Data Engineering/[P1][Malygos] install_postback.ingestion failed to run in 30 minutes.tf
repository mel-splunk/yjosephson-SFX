# [P1][Malygos] install_postback.ingestion failed to run in 30 minutes
resource "signalfx_detector" "p1_malygos_install_postback_ingestion_failed_to_run_in_30_minutes" {
	count = "1"
	name = "[P1][Malygos] install_postback.ingestion failed to run in 30 minutes"
	description = "Streaming pipeline which loads data from install_postback topic and perform etl on them and insert into cheezit install_postback table."

	program_text = <<-EOF
		signal = data('malygos.install_postback.ingestion.success', filter=filter('environment', 'prod'), rollup='average').sum(over='30m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum < 1 for last 30m"
		severity = "Critical"
		detect_label = "Processing messages last 30m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
