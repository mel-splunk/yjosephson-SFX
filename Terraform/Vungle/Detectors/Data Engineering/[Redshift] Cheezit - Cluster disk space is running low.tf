# [Redshift] Cheezit - Cluster disk space is running low
resource "signalfx_detector" "redshift_cheezit_cluster_disk_space_is_running_low" {
	count = "1"
	name = "[Redshift] Cheezit - Cluster disk space is running low"
	description = "Cheezit is running very low on disk. This needs to be addressed immediately before all queries start to fail"

	program_text = <<-EOF
		signal = data('PercentageDiskSpaceUsed', filter=filter('namespace', 'AWS/Redshift') and filter('ClusterIdentifier', 'cheezit'), rollup='average').mean(over='15m')
		detect(when(signal > 96)).publish('CRIT')
	EOF

	rule {
		description = "Average > 96 for last 15m"
		severity = "Critical"
		detect_label = "Processing messages last 15m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
