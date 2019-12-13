# [P2][Malygos] edsp.aggregation publisher report count too low
resource "signalfx_detector" "p2_malygos_edsp_aggregation_publisher_report_count_too_low" {
	name = "[P2][Malygos] edsp.aggregation publisher report count too low"
	description = "Batch pipeline which consumes data from cheezit edsp_transactions table and performs aggregation by mutiple dimensions for several metrics calculation and ship the results into cheezit's publisher_report and edsp_report table"

program_text = <<-EOF
		A = data('malygos.edsp.aggregation.publisherReportCount', filter=filter('environment', 'prod'), rollup='average').max(over='2h')
		detect(when(signal < 1200)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max < 1200 for last 2h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
