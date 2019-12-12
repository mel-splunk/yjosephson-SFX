# [P2][Malygos] hbp.win_ingestion failed to run in last 4 hours
resource "signalfx_detector" "p2_malygos_hbp_win_ingestion_failed_to_run_in_last_4_hours" {
	count = "1"
	name = "[P2][Malygos] hbp.win_ingestion failed to run in last 4 hours"
	description = "Hbp.win_ingestion failed to run in last 4 hours"

	program_text = <<-EOF
		signal = data('malygos.hbp.win_ingestion.success', filter=filter('environment', 'prod'), rollup='sum').sum(over='4h').min(over='4h')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum < 1 for last 4h"
		severity = "Critical"
		detect_label = "Processing messages last 4h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
