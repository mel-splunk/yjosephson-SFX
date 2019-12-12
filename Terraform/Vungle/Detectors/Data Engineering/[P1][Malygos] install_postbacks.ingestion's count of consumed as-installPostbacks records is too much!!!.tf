# [P1][Malygos] install_postbacks.ingestion's count of consumed as-installPostbacks records is too much!!!
resource "signalfx_detector" "p1_malygos_install_postbacks_ingestion_s_count_of_consume_as_installpostbacks_records_is_too_much" {
	count = "1"
	name = "[P1][Malygos] install_postbacks.ingestion's count of consumed as-installPostbacks records is too much!!!"
	description = "Streaming pipeline which loads data from install_postback topic and performs ETL on them and inserts into Cheezit install_postback table."

	program_text = <<-EOF
		signal = data('malygos.install_postback.ingestion.streaming.consumed.records', filter=filter('environment', 'prod'), rollup='average').max(over='1h')
		detect(when(signal >= 3000000)).publish('CRIT')
	EOF

	rule {
		description = "Max > 3000000 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
