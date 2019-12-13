# [Malygos] IDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found
resource "signalfx_detector" "malygos_idsp_aggregation_account_id_for_publisher_or_advertiser_cannot_be_found" {
	name = "[Malygos] IDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found"
	description = "Rows in idsp_transactions table do not have matching Account ID"

	program_text = <<-EOF
		A = data('malygos.idsp.aggregation.publisherLostAccountId', filter=filter('environment', 'prod'), rollup='average')
		B = data('malygos.idsp.aggregation.advertiserLostAccountId', filter=filter('environment', 'prod'), rollup='average')
		signal = (A+B).max(over='1h')
		detect(when(signal > 100)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max > 100 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
