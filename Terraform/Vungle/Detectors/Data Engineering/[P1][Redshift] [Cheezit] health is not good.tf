# [P1][Redshift] [Cheezit] health is not good
resource "signalfx_detector" "p1_redshift_cheezit_health_is_not_good" {
	count = "1"
	name = "[P1][Redshift] [Cheezit] health is not good"
	description = "Cheezit cluster health_status."

	program_text = <<-EOF
		signal = data('HealthStatus', filter=filter('namespace', 'AWS/Redshift') and filter('ClusterIdentifier', 'cheezit'), rollup='average').min(over='10m')
		detect(when(signal <= 0.99)).publish('CRIT')
	EOF

	rule {
		description = "Min <= 0.99 for last 10m"
		severity = "Critical"
		detect_label = "Processing messages last 10m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
