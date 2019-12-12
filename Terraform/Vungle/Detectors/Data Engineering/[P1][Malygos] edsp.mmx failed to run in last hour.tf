# [P1][Malygos] edsp.mmx failed to run in last hour
resource "signalfx_detector" "p1_malygos_edsp_mmx_failed_to_run_in_last_hour" {
	count = "1"
	name = "[P1][Malygos] edsp.mmx failed to run in last hour"
	description = "Batch pipeline which loads data from cheezit edsp_transactions table and perform ETL on them and ship the results to S3 vungle-mmx-share/gallywix/mmx bucket so that MMX could pick them up and show the results on their dashboard."

	program_text = <<-EOF
		signal = data('malygos.edsp.mmx.success', filter=filter('environment', 'prod'), rollup='average').sum(over='1h')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum < 1 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
