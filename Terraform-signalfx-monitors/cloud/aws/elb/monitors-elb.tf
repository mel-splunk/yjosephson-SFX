resource "signalfx_detector" "ELB_no_healthy_instances" {
	name = "ELB healthy instances"

	program_text = <<-EOF
		A = data('HealthyHostCount', filter=filter('namespace', 'AWS/ELB')).sum(by=['aws_region','LoadBalancerName'])
		B = data('UnHealthyHostCount', filter=filter('namespace', 'AWS/ELB')).sum(by=['aws_region','LoadBalancerName'])
		signal = (A/ (A + B)).scale(100).min(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Min < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "ELB_too_much_4xx" {
	name = "ELB 4xx errors too high"

	program_text = <<-EOF
		A = data('HTTPCode_ELB_4XX', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName'])
		B = data('RequestCount', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName'])
		signal = (A/ (B + 5)).scale(100).sum(over='5m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "ELB_too_much_5xx" {
	name = "ELB 5xx errors too high"

	program_text = <<-EOF
		A = data('HTTPCode_ELB_5XX', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName'])
		B = data('RequestCount', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName'])
		signal = (A/ (B + 5)).scale(100).sum(over='5m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "ELB_too_much_4xx_backend" {
	name = "ELB backend 4xx errors too high"

	program_text = <<-EOF
		A = data('HTTPCode_Backend_4XX', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName'])
		B = data('RequestCount', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName'])
		signal = (A/ (B + 5)).scale(100).sum(over='5m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "ELB_too_much_5xx_backend" {
	name = "ELB backend 5xx errors too high"

	program_text = <<-EOF
		A = data('HTTPCode_Backend_5XX', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName'])
		B = data('RequestCount', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName'])
		signal = (A/ (B + 5)).scale(100).sum(over='5m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "ELB_backend_latency" {
	name = "ELB latency too high"

	program_text = <<-EOF
		signal = data('Latency', filter=filter('namespace', 'AWS/ELB'), extrapolation='zero', rollup='rate').mean(by=['aws_region','LoadBalancerName']).min(over='5m')
		detect(when(signal > 3)).publish('CRIT')
	EOF

	rule {
		description = "Min > 3 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
