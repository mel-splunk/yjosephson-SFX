# [Redshift] [cheezit] CPU utilisation and WLM Queue Length for Redshift cluster
resource "signalfx_detector" "redshift_cheezit_cpu_utilisation_and_wlm_queue_length_for_redshift_cluster" {
	count = "1"
	name = "[Redshift] [cheezit] CPU utilisation and WLM Queue Length for Redshift cluster"
	description = "This is part of a composite monitor for an ongoing issue"

	program_text = <<-EOF
		A = data('CPUUtilization', filter=filter('namespace', 'AWS/Redshift') and filter('ClusterIdentifier', 'cheezit'), rollup='average').mean(over='5m')
		B = data('WLMQueueLength', filter=filter('namespace', 'AWS/Redshift') and filter('ClusterIdentifier', 'cheezit'), rollup='average').mean(over='1m')
		detect((when(A < 5) and when(B > 5))).publish('CRIT')
	EOF

	rule {
		description = "When CPUUtlization < 5 last 5m and WLMQueueLength > 5 last 1m"
		severity = "Critical"
		detect_label = "Processing messages last 5m and 1m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
