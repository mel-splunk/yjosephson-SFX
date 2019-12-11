# [Malygos] IDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found
resource "signalfx_detector" "[Malygos] IDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] IDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found"
  description = "Rows in idsp_transactions table do not have matching Account ID"

/*  query = <<EOQ
    max(last_1h):avg:malygos.idsp.aggregation.publisherLostAccountId{env:prod} + avg:malygos.idsp.aggregation.advertiserLostAccountId{env:prod} > 100
  EOQ*/

  program_text = <<-EOF
      A = data('malygos.idsp.aggregation.publisherLostAccountId', filter=filter('environment', 'prod'))
      B = data('malygos.idsp.aggregation.advertiserLostAccountId', filter=filter('environment', 'prod'))
  
      signal = (A+B).max(over='1h')
			detect(when(signal > 100)).publish('CRIT')

  EOF

	rule {
		description = "Max > 100 for last 1h"
		severity = "Critical"
	}

}
