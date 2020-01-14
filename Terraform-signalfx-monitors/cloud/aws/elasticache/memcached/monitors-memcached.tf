resource "signalfx_detector" "memcached_get_hits" {
	name = "Elasticache memcached cache hit ratio"

	program_text = <<-EOF
		A = data('GetHits', filter=filter('namespace', 'AWS/ElastiCache'), rollup='rate', extrapolation='zero').mean(by=['aws_region','CacheClusterId','CacheNodeId'])
		B = data('GetMisses', filter=filter('namespace', 'AWS/ElastiCache'), rollup='rate', extrapolation='zero').mean(by=['aws_region','CacheClusterId','CacheNodeId'])
		signal = (A/(A+B)).scale(100).max(over='15m')
		detect(when(signal < 60)).publish('CRIT')
	EOF

	rule {
		description = "Max < 60 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "memcached_cpu_high" {
	name = "Elasticache memcached CPU"

	program_text = <<-EOF
		signal = data('CPUUtilization', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
