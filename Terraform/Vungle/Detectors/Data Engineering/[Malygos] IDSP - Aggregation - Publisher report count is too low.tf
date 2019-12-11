# [Malygos] IDSP - Aggregation - Publisher report count is too low
resource "signalfx_detector" "[Malygos] IDSP - Aggregation - Publisher report count is too low" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] IDSP - Aggregation - Publisher report count is too low"
  description = "Last IDSP aggregation processed only"

/*  query = <<EOQ
    max(last_2h):avg:malygos.idsp.aggregation.publisherReportCount{env:prod} < 50000
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.idsp.aggregation.publisherReportCount', filter=filter('environment', 'prod')).max(over='2h')
      
			detect(when(signal < 50000)).publish('CRIT')

  EOF

	rule {
		description = "Max < 50000 for last 2h"
		severity = "Critical"
	}

}
