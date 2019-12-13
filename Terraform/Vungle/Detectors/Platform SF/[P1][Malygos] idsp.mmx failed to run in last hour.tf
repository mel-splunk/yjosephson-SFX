# [P1][Malygos] idsp.mmx failed to run in last hour
resource "signalfx_detector" "p1_malygos_idsp_mmx_failed_to_run_in_last_hour" {
	name = "[P1][Malygos] idsp.mmx failed to run in last hour"
	description = "Batch pipeline which loads data from cheezit idsp_transactions table and performs ETL on them and ships the results to S3 vungle-mmx-share/gallywix/mmx bucket so that MMX could pick them up and show the results on their dashboard"

program_text = <<-EOF
		A = data('malygos.idsp.mmx.success', filter=filter('environment', 'prod'), rollup='average').sum(over='1h')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum < 1 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
