# [P1][Malygos] idsp.mmx MetaMarket transaction count too low
resource "signalfx_detector" "p1_malygos_idsp_mmx_metamarket_transaction_count_too_low" {
	name = "[P1][Malygos] idsp.mmx MetaMarket transaction count too low"
	description = "Batch pipeline which loads data from cheezit idsp_transactions table and perform ETL on them and ship the results to S3 vungle-mmx-share/gallywix/mmx bucket so that MMX could pick them up and show the results on their dashboard"

program_text = <<-EOF
		A = data('malygos.idsp.mmx.transactions', filter=filter('environment', 'prod'), rollup='average').max(over='4h')
		detect(when(signal < 1000000)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max < 1000000 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
