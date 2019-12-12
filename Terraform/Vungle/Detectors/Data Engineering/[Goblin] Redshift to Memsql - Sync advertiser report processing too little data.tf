# [Goblin] Redshift to Memsql - Sync advertiser report processing too little data
resource "signalfx_detector" "goblin_redshift_to_memsql_sync_advertiser_report_processing_too_little_data" {
	count = "1"
	name = "[Goblin] Redshift to Memsql - Sync advertiser report processing too little data"
	description = "Sync advertiser report processing too little data"

	program_text = <<-EOF
		signal = data('goblin.redshift2memsql.advertiser_report_column.rows', rollup='average').mean(over='1h')
		detect(when(signal < 50000)).publish('CRIT')
	EOF

	rule {
		description = "Count < 50000 for last 1h"
		severity = "Critical"
		detect_label  = "Processing messages for last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
