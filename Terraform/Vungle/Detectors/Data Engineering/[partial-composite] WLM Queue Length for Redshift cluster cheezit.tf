# [partial-composite] WLM Queue Length for Redshift cluster cheezit
resource "signalfx_detector" "partial_composite_wlm_queue_length_for_redshift_cluster_cheezit" {
	count = "1"
	name = "[partial-composite] WLM Queue Length for Redshift cluster cheezit"
	description = "This is part of a composite monitor for an ongoing issue"

	program_text = <<-EOF
		signal = data('WLMQueueLength', filter=filter('namespace', 'AWS/Redshift') and filter('ClusterIdentifier', 'cheezit'), rollup='average').mean(over='1m')
		detect(when(signal > 5)).publish('CRIT')
	EOF

	rule {
		description = "Average > 5 for last 1m"
		severity = "Critical"
		detect_label = "Processing messages last 1m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
