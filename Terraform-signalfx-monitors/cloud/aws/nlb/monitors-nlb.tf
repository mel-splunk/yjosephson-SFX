resource "signalfx_detector" "NLB_no_healthy_instances" {
	name = "NLB healthy instances"

	program_text = <<-EOF
		A = data('HealthyHostCount', filter=filter('namespace', 'AWS/NetworkELB')).sum(by=['aws_region','LoadBalancerName'])
		B = data('UnHealthyHostCount', filter=filter('namespace', 'AWS/NetworkELB')).sum(by=['aws_region','LoadBalancerName'])
		signal = (A / (A+B)).scale(100).min(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Min < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
