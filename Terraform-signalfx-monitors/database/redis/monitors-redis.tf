#
# Service Check
#
resource "signalfx_detector" "not_responding" {
	name = "Redis does not respond"

	/*query = <<EOQ
		"redis.can_connect"${module.filter-tags.service_check}.by("redis_host","redis_port").last(6).count_by_status()
EOQ*/

}

resource "signalfx_detector" "evicted_keys" {
	name = "Redis evicted keys"

	program_text = <<-EOF
		signal = data('counter.evicted_keys', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port']).mean(over='5m')
		detect(when(signal > 100)).publish('CRIT')
	EOF

	rule {
		description = "Average > 100 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "expirations" {
	name = "Redis expired keys"

	program_text = <<-EOF
		A = data('gauge.db0_expires', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port'])
		B = data('gauge.db0_keys', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 80)).publish('CRIT')
	EOF

	rule {
		description = "Min > 80 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "blocked_clients" {
	name = "Redis blocked clients"

	program_text = <<-EOF
		A = data('gauge.blocked_clients', filter=filter('plugin', 'redis_info')).sum(by=['host', 'port'])
		B = data('gauge.connected_clients', filter=filter('plugin', 'redis_info')).sum(by=['host', 'port'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 30)).publish('CRIT')
	EOF

	rule {
		description = "Min > 30 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "keyspace_full" {
	name = "Redis keyspace seems full (no changes since ${var.keyspace_timeframe})"

	program_text = <<-EOF
		signal = data('gauge.db0_keys', filter=filter('plugin', 'redis_info')).delta(by=['host', 'port']).abs().min(over='5m')
		detect(when(signal == 0)).publish('CRIT')
	EOF

	rule {
		description = "Min == 0 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "memory_used" {
	name = "Redis memory used"

	program_text = <<-EOF
		A = data('bytes.used_memory', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port'])
		B = data('bytes.used_memory_peak', filter=filter('plugin', 'redis_info')).max(by=['host', 'port'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "memory_frag" {
	name = "Redis memory fragmented"

	program_text = <<-EOF
		A = data('gauge.mem_fragmentation_ratio', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port'])
		signal = (A*100).min(over='5m')
		detect(when(signal > 150)).publish('CRIT')
	EOF

	rule {
		description = "Min > 150 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "rejected_connections" {
	name = "Redis rejected connections"

	program_text = <<-EOF
		signal = data('counter.rejected_connections', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port']).min(over='5m')
		detect(when(signal > 50)).publish('CRIT')
	EOF

	rule {
		description = "Min > 50 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "latency" {
	name = "Redis latency"

	/*query = <<EOQ
		change(${var.latency_time_aggregator}(${var.latency_timeframe}),${var.latency_timeframe}): (
			avg:redis.info.latency_ms${module.filter-tags.query_alert} by {redis_host,redis_port}
		 ) > ${var.latency_threshold_critical}
EOQ*/

	program_text = <<-EOF
		signal = data('XXXX', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port']).min(over='5m')
		detect(when(signal > 100)).publish('CRIT')
	EOF

	rule {
		description = "Min > 100 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "hitrate" {
	name = "Redis hitrate"

	program_text = <<-EOF
		A = data('derive.keyspace_hits', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port'])
		B = data('derive.keyspace_misses', filter=filter('plugin', 'redis_info')).mean(by=['host', 'port'])
		signal = ((A/(A+B))*100).max(over='5m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Max < 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
