# [Malygos] IDSP - Aggregation - Publisher report count is too low
resource "signalfx_detector" "malygos_idsp_aggregation_publisher_report_count_is_too_low" {
	name = "[Malygos] IDSP - Aggregation - Publisher report count is too low"
	description = "Last IDSP aggregation processed only"

	program_text = <<-EOF
		signal = data('malygos.idsp.aggregation.publisherReportCount', filter=filter('environment', 'prod'), rollup='average').max(over='2h')
		detect(when(signal < 50000)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max < 50000 for last 2h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
