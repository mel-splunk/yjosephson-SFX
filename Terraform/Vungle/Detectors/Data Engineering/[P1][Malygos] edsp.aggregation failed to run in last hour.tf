# [P1][Malygos] edsp.aggregation failed to run in last hour
resource "signalfx_detector" "[P1][Malygos] edsp.aggregation failed to run in last hour" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] edsp.aggregation failed to run in last hour"
  description = "Batch pipeline which consumes data from cheezit edsp_transactions table and performs aggregation by mutiple dimensions for several metrics calculation and ship the results into cheezit's publisher_report and edsp_report table."

/*  query = <<EOQ
    sum(last_1h):avg:malygos.edsp.aggregation.success{env:prod} < 1
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.edsp.aggregation.success', filter=filter('environment', 'prod'), rollup='average').sum(over='1h')

			detect(when(signal < 1)).publish('CRIT')

  EOF

	rule {
		description = "Sum < 1 for last 1h"
		severity = "Critical"
	}

}
