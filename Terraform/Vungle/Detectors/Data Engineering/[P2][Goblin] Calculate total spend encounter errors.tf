# [P2][Goblin] Calculate total spend encounter errors
resource "signalfx_detector" "p2_goblin_calculate_total_spend_encounter_errors" {
	count = "1"
	name = "[P2][Goblin] Calculate total spend encounter errors"
	description = "Batch pipeline which move data from Memsql advertiser_report_daily table into MongoDB vvv-repl campaigns collection."

	program_text = <<-EOF
		signal = data('goblin.total_and_recent.mongodb.errors', rollup='average').max(over='2h')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Max > 1 for last 2h"
		severity = "Critical"
		detect_label = "Processing messages last 2h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
