# [P2][Malygos] PA views table dump to parquet count too low
resource "signalfx_detector" "p2_malygos_pa_views_table_dump_to_parquet_count_too_low" {
	count = "1"
	name = "[P2][Malygos] PA views table dump to parquet count too low"
	description = "Batch job which daily dump views and clicks table to parquet on S3. Add parttion to external table for PA redshift cluster."

	program_text = <<-EOF
		signal = data('malygos.pa.dump.views.output.count', filter=filter('environment', 'prod'), rollup='average').max(over='1d')
		detect(when(signal < 1000000)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1000000 for last 1d"
		severity = "Critical"
		detect_label = "Processing messages last 1d"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
