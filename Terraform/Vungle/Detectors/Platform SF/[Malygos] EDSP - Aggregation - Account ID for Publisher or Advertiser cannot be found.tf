# [Malygos] EDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found
resource "signalfx_detector" "malygos_edsp_aggregation_account_id_for_publisher_or_advertiser_cannot_be_found" {
	name = "[Malygos] EDSP - Aggregation - Account ID for Publisher or Advertiser cannot be found"
	description = "Rows in edsp_transactions table do not have matching Account ID"

	program_text = <<-EOF
		A = data('malygos.edsp.aggregation.publisherLostAccountId', filter=filter('environment', 'prod'), rollup='average')
		B = data('malygos.edsp.aggregation.edspLostAccountId', filter=filter('environment', 'prod'), rollup='average')
		signal = (A+B).max(over='1h')
		detect(when(signal > 0.5 )).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average > 0.5 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
