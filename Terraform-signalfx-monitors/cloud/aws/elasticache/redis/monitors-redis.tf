resource "signalfx_detector" "redis_cache_hits" {
	name = "Elasticache redis cache hit ratio"

	program_text = <<-EOF
		A = data('CacheHits', filter=filter('namespace', 'AWS/ElastiCache'), rollup='rate', extrapolation='zero').mean(by=['aws_region','CacheClusterId','CacheNodeId'])
		B = data('CacheMisses', filter=filter('namespace', 'AWS/ElastiCache'), rollup='rate', extrapolation='zero').mean(by=['aws_region','CacheClusterId','CacheNodeId'])
		signal = (A/(A+B)).scale(100).max(over='15m')
		detect(when(signal < 60)).publish('CRIT')
	EOF

	rule {
		description = "Max < 60 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "redis_cpu_high" {
	name = "Elasticache redis CPU"

	program_text = <<-EOF
		signal = data('EngineCPUUtilization', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "redis_replication_lag" {
	name = "Elasticache redis replication lag"

	program_text = <<-EOF
		signal = data('ReplicationLag', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).min(over='10m')
		detect(when(signal > 180)).publish('CRIT')
	EOF

	rule {
		description = "Min > 180 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "redis_commands" {
	name = "Elasticache redis is receiving no commands"

	program_text = <<-EOF
		A = data('GetTypeCmds', filter=filter('namespace', 'AWS/ElastiCache'), rollup='sum').mean(by=['aws_region','CacheClusterId','CacheNodeId'])
		B = data('SetTypeCmds', filter=filter('namespace', 'AWS/ElastiCache'), rollup='sum').mean(by=['aws_region','CacheClusterId','CacheNodeId'])
		signal = (A + B).sum(over='5m')
		detect(when(signal <= 0 )).publish('CRIT')
	EOF

	rule {
		description = "Sum <= 0 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
