resource "signalfx_detector" "elasticache_eviction" {
	name = "Elasticache eviction"

	program_text = <<-EOF
		signal = data('Evictions', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).sum(over='15m')
		detect(when(signal > 30)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 30 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "elasticache_max_connection" {
	name = "Elasticache max connections reached"

	program_text = <<-EOF
		signal = data('CurrConnections', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).max(over='5m')
		detect(when(signal >= 65000)).publish('CRIT')
	EOF

	rule {
		description = "Max >= 65000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "elasticache_no_connection" {
	name = "Elasticache connections"

	program_text = <<-EOF
		signal = data('CurrConnections', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).min(over='5m')
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	rule {
		description = "Min <= 0 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "elasticache_swap" {
	name = "Elasticache swap"

	program_text = <<-EOF
		signal = data('SwapUsage', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).min(over='5m')
		detect(when(signal > 50000000)).publish('CRIT')
	EOF

	rule {
		description = "Min > 50000000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "elasticache_free_memory" {
	name = "Elasticache free memory"

	/*query = <<EOQ
		pct_change(avg(last_15m)):
			avg:aws.elasticache.freeable_memory${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
		< ${var.free_memory_threshold_critical}
	EOQ*/

	program_text = <<-EOF
		/* Need to figure out what pct_change is */
		signal = data('FreeableMemory', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).mean(over='15m')
		detect(when(signal < -70)).publish('CRIT')
	EOF

	rule {
		description = "Average < -70 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "elasticache_eviction_growing" {
	name = "Elasticache evictions is growing"

	program_text = <<-EOF
	/* Need to figure out what pct_change is */
		signal = data('Evictions', filter=filter('namespace', 'AWS/ElastiCache')).mean(by=['aws_region','CacheClusterId','CacheNodeId']).mean(over='5m')
		detect(when(signal > 30)).publish('CRIT')
	EOF

	rule {
		description = "Average > 30 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
