# [P1][Malygos] edsp.aggregation failed to run in last hour
resource "signalfx_detector" "p1_malygos_edsp_aggregation_failed_to_run_in_last_hour" {
	name = "[P1][Malygos] edsp.aggregation failed to run in last hour"
	description = "Batch pipeline which consumes data from cheezit edsp_transactions table and performs aggregation by mutiple dimensions for several metrics calculation and ship the results into cheezit's publisher_report and edsp_report table"

	program_text = <<-EOF
		signal = data('malygos.edsp.aggregation.success', filter=filter('environment', 'prod'), rollup='average').sum(over='1h')
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
