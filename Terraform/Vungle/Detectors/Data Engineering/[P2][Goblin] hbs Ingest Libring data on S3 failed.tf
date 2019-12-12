# [P2][Goblin] hbs Ingest Libring data on S3 failed
resource "signalfx_detector" "p2_goblin_hbs_ingest_libring_data_on_s3_failed" {
	count = "1"
	name = "[P2][Goblin] hbs Ingest Libring data on S3 failed"
	description = "Batch pipeline which moves report data from S3 which generated by Libring to Cheezit hbs_external_raw table."

	program_text = <<-EOF
		signal = data('goblin.s3_to_redshift.hbs_external_raw.success', rollup='min').min(over='1h')
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	rule {
		description = "Min <= 0 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}