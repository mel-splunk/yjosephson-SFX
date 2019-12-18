# Meister Instances are not responding with bids
resource "signalfx_detector" "meister_instances_are_not_responding_with_bids" {
	name = "Meister Instances are not responding with bids"
	description = "Meister is not bidding"

	program_text = <<-EOF
		signal = data('dsp.meister.bidresponse.serve.bid', filter=filter('environment', 'api-gke'), rollup='count').sum(over='5m')
		detect(when(signal < 1000)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum < 1000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
