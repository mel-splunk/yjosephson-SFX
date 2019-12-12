# [P1][Malygos] requests_no_fill.aggregation failed to run in last hour
resource "signalfx_detector" "p1_malygos_requests_no_fill_aggregation_failed_to_run_in_last_hour" {
	count = "1"
	name = "[P1][Malygos] requests_no_fill.aggregation failed to run in last hour"
	description = "Batch pipeline which loads data from Cheezit requests_no_fill table and perform aggregation on them and insert results into  publisher_report table."

	program_text = <<-EOF
		signal = data('malygos.requests_no_fill.aggregation.success', filter=filter('environment', 'prod'), rollup='average').sum(over='1h')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum < 1 for last 1h"
		severity = "Critical"
		detect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
