# [P1][Redshift] [Cheezit] CPU used is high
resource "signalfx_detector" "p1_redshift_cheezit_cpu_used_is_high" {
	count = "1"
	name = "[P1][Redshift] [Cheezit] CPU used is high"
	description = "Cheezit redshift cluster cpu is high."

	program_text = <<-EOF
		signal = data('CPUUtilization', filter=filter('namespace', 'AWS/Redshift') and filter('ClusterIdentifier', 'cheezit'), rollup='average').min(over='10m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 95 for last 10m"
		severity = "Critical"
		detect_label = "Processing messages last 10m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
