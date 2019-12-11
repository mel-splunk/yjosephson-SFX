# [Malygos] EDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found
resource "signalfx_detector" "[Malygos] EDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] EDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found"
  description = "Rows in edsp_transactions table do not have matching Account ID"

/*  query = <<EOQ
    max(last_1h):avg:malygos.edsp.aggregation.publisherLostAccountId{env:prod} + avg:malygos.edsp.aggregation.edspLostAccountId{env:prod} > 0.5
  EOQ*/

  program_text = <<-EOF
      A = data('malygos.edsp.aggregation.publisherLostAccountId', filter=filter('environment', 'prod'))
      B = data('malygos.edsp.aggregation.edspLostAccountId', filter=filter('environment', 'prod'))
			
      signal = (A + B).max(over='1h')
			detect(when(signal > 0.5)).publish('CRIT')

  EOF

	rule {
		description = "Average > 0.5 for last 1h"
		severity = "Critical"
	}

}
