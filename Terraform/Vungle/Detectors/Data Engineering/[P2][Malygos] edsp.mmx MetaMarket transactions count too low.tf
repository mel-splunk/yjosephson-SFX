# [P2][Malygos] edsp.mmx MetaMarket transactions count too low
resource "signalfx_detector" "p2_malygos_edsp_mmx_metamarket_transactions_count_too_low" {
	count = "1"
	name = "[P2][Malygos] edsp.mmx MetaMarket transactions count too low"
	description = "Batch pipeline which consumes data from Cheezit edsp_transactions table and performs ETL on them and ships the results to S3 so that MMX could pick them up and show them on the MMX dashboard."

	program_text = <<-EOF
		signal = data('malygos.edsp.mmx.transactions', filter=filter('environment', 'prod'), rollup='average').max(over='2h')
		detect(when(signal < 5000)).publish('CRIT')
	EOF

	rule {
		description = "Max < 5000 for last 2h"
		severity = "Critical"
		detect_label = "Processing messages last 2h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
