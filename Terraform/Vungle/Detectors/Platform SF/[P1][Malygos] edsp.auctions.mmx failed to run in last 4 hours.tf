# [P1][Malygos] edsp.auctions.mmx failed to run in last 4 hours
resource "signalfx_detector" "p1_malygos_edsp_auctions_mmx_failed_to_run_in_last_4_hours" {
	name = "[P1][Malygos] edsp.auctions.mmx failed to run in last 4 hours"
	description = "Batch pipeline which consumes data from cheezit edsp_auctions table and perform ETL on them and ship the results to S3 so that MMX could pick them up and show on the MMX dashboard"

	program_text = <<-EOF
		signal = data('malygos.edsp_auctions.mmx.success', filter=filter('environment', 'prod'), rollup='average').sum(over='4h')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum < 1 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
