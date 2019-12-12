# [P2][Goblin] Sync cpa_report(ltv_value) encounter error
resource "signalfx_detector" "p2_goblin_sync_cpa_report_ltv_value_encounter_error" {
	count = "1"
	name = "[P2][Goblin] Sync cpa_report(ltv_value) encounter error"
	description = "Batch pipeline which sync data from Cheezit cpa_report table to memsql cpa_report table. The table are used by Medivh."

	program_text = <<-EOF
		signal = data('goblin.redshift2memsql.sync_cpa_report.yesterday.ltv_values', rollup='average').min(over='2h')
		detect(when(signal < 0)).publish('CRIT')
	EOF

	rule {
		description = "Min < 0 for last 2h"
		severity = "Critical"
		detect_label = "Processing messages last 2h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
