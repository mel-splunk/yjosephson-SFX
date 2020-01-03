#
# Service Check
#
/*resource "signalfx_detector" "not_responding" {
	name = "ElasticSearch does not respond"
	
	query = <<EOQ
		"elasticsearch.can_connect"${module.filter-tags.service_check}.by("server","port").last(6).count_by_status()
EOQ

	thresholds = {
		warning  = var.not_responding_threshold_warning
		critical = 5
	}

	no_data_timeframe   = var.not_responding_no_data_timeframe
	new_host_delay      = var.new_host_delay
	notify_no_data      = true
	notify_audit        = false
	locked              = false
	timeout_h           = 0
	include_tags        = true
	require_full_window = true
	renotify_interval   = 0

	tags = concat(["env:${var.environment}", "type:database", "provider:elasticsearch", "resource:elasticsearch", "team:claranet", "created-by:terraform"], var.not_responding_extra_tags)

	lifecycle {
		ignore_changes = ["silenced"]
	}
}*/

#
# Cluster Status Not Green
#
resource "signalfx_detector" "cluster_status_not_green" {
	name = "ElasticSearch Cluster status not green"

	program_text = <<-EOF
		signal = data('gauge.cluster.status', filter=filter('plugin', 'elasticsearch')).min(by=['cluster_name']).mean(over='5m')
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	rule {
		description = "Average <= 0 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Cluster Initializing Shards
#
resource "signalfx_detector" "cluster_initializing_shards" {
	name = "ElasticSearch Cluster is initializing shards"

	program_text = <<-EOF
		signal = data('gauge.cluster.initializing-shards', filter=filter('plugin', 'elasticsearch')).mean(by=['cluster_name']).mean(over='5m')
		detect(when(signal > 2)).publish('CRIT')
	EOF

	rule {
		description = "Average > 2 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Cluster Relocating Shards
#
resource "signalfx_detector" "cluster_relocating_shards" {
	name = "ElasticSearch Cluster is relocating shards"

	program_text = <<-EOF
		signal = data('gauge.cluster.relocating-shards', filter=filter('plugin', 'elasticsearch')).mean(by=['cluster_name']).mean(over='5m')
		detect(when(signal > 2)).publish('CRIT')
	EOF

	rule {
		description = "Average > 2 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Cluster Unassigned Shards
#
resource "signalfx_detector" "cluster_unassigned_shards" {
	name = "ElasticSearch Cluster has unassigned shards"

	program_text = <<-EOF
		signal = data('gauge.cluster.unassigned-shards', filter=filter('plugin', 'elasticsearch')).mean(by=['cluster_name']).mean(over='5m')
		detect(when(signal > 2)).publish('CRIT')
	EOF

	rule {
		description = "Average > 2 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Free Space in nodes
#
resource "signalfx_detector" "node_free_space" {
	name = "ElasticSearch free space < 10%"

	/*query = <<EOQ
	sum (last 5m
		(min:elasticsearch.fs.total.available_in_bytes${module.filter-tags.query_alert} by {node_name}
		/
		min:elasticsearch.fs.total.total_in_bytes${module.filter-tags.query_alert} by {node_name}
		) * 100
	< 10
EOQ*/

	program_text = <<-EOF
		A = data('gauge.XXX', filter=filter('plugin', 'elasticsearch')).Minimum(by=['node_name'])
		B = data('gauge.XXX', filter=filter('plugin', 'elasticsearch')).Minimum(by=['node_name'])
		signal = (A/B).scale(100).sum(over='5m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Sum < 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# JVM Heap Memory Usage
#
resource "signalfx_detector" "jvm_heap_memory_usage" {
	name = "Elasticsearch JVM HEAP memory usage"

	program_text = <<-EOF
		signal = data('gauge.jvm.mem.heap-used', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name']).mean(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# JVM Memory Young Usage
#
resource "signalfx_detector" "jvm_memory_young_usage" {
	name = "Elasticsearch JVM memory Young usage"

	program_text = <<-EOF
		A = data('gauge.jvm.mem.pools.young.used_in_bytes', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name'])
		B = data('gauge.jvm.mem.pools.young.max_in_bytes', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name'])
		signal = (A/B).scale(100).mean(over='10m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# JVM Memory Old Usage
#
resource "signalfx_detector" "jvm_memory_old_usage" {
	name = "Elasticsearch JVM memory Old usage"

	program_text = <<-EOF
		A = data('gauge.jvm.mem.pools.old.used_in_bytes', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name'])
		B = data('gauge.jvm.mem.pools.old.max_in_bytes', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name'])
		signal = (A/B).scale(100).mean(over='10m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# JVM Garbace Collector Old Collection Latency
#
resource "signalfx_detector" "jvm_gc_old_collection_latency" {
	name = "Elasticsearch average Old-generation garbage collections latency"

	program_text = <<-EOF
		A = data('counter.jvm.gc.old-time', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		B = data('counter.jvm.gc.old-count', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		signal = (A/B).scale(1000).mean(over='15m')
		detect(when(signal > 300)).publish('CRIT')
	EOF

	rule {
		description = "Average > 300 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# JVM Garbace Collector Young Collection Latency
#
resource "signalfx_detector" "jvm_gc_young_collection_latency" {
	name = "Elasticsearch average Young-generation garbage collections latency"

	program_text = <<-EOF
		A = data('counter.jvm.gc.time', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		B = data('counter.jvm.gc.count', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		signal = (A/B).scale(1000).mean(over='15m')
		detect(when(signal > 40)).publish('CRIT')
	EOF

	rule {
		description = "Average > 40 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Indexing Latency
#
resource "signalfx_detector" "indexing_latency" {
	name = "Elasticsearch average indexing latency by document"

	program_text = <<-EOF
		A = data('counter.indices.indexing.index-time', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		B = data('counter.indices.indexing.index-total', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		signal = (A/B).scale(1000).mean(over='10m')
		detect(when(signal > 30)).publish('CRIT')
	EOF

	rule {
		description = "Average > 30 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Flush Latency
#
resource "signalfx_detector" "flush_latency" {
	name = "Elasticsearch average index flushing to disk latency"

	program_text = <<-EOF
		A = data('counter.indices.flush.time', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		B = data('counter.indices.flush.total', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		signal = (A/B).scale(1000).mean(over='15m')
		detect(when(signal > 150)).publish('CRIT')
	EOF

	rule {
		description = "Average > 150 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Open HTTP Connections Anomaly
#
resource "signalfx_detector" "http_connections_anomaly" {
	name = "Elasticsearch number of current open HTTP connections anomaly detected"

	/*query = <<EOQ
	avg (last 4h):
		anomalies(avg:elasticsearch.http.current_open${module.filter-tags.query_alert} by {node_name},
							'agile',
							2,
							direction='above',
							alert_window='last_15m',
							interval=60,
							count_default_zero='true',
							seasonality='hourly'
							)
	>= 1
EOQ*/

	program_text = <<-EOF
		signal = data('gauge.http.current_open', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name']).mean(over='4h')
		detect(when(signal >= 1)).publish('CRIT')
	EOF

	rule {
		description = "Average >= 1 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Query Latency
#
resource "signalfx_detector" "search_query_latency" {
	name = "Elasticsearch average search query latency"

	program_text = <<-EOF
		A = data('counter.indices.search.query-time', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		B = data('counter.indices.search.query-total', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		signal = (A/B).scale(1000).mean(over='15m')
		detect(when(signal > 20)).publish('CRIT')
	EOF

	rule {
		description = "Average > 20 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Fetch Latency
#
resource "signalfx_detector" "fetch_latency" {
	name = "Elasticsearch average search fetch latency"

	program_text = <<-EOF
		A = data('counter.indices.search.fetch-time', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		B = data('counter.indices.search.fetch-total', filter=filter('plugin', 'elasticsearch')).delta().mean(by=['node_name'])
		signal = (A/B).scale(1000).min(over='15m')
		detect(when(signal > 20)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 20 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Search Query Change
#
resource "signalfx_detector" "search_query_change" {
	name = "Elasticsearch change alert on the number of currently active queries"

	/*query = <<EOQ
	pct_change(avg (last_10m), lash_10m):
		avg:elasticsearch.search.query.current${module.filter-tags.query_alert} by {cluster_name}
	>= 100
EOQ*/

	program_text = <<-EOF
		signal = data('gauge.indices.search.query-current', filter=filter('plugin', 'elasticsearch')).mean(by=['cluster_name']).mean(over='10m')
		detect(when(signal >= 100)).publish('CRIT')
	EOF

	rule {
		description = "Average >= 100 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Fetch Change
#
resource "signalfx_detector" "fetch_change" {
	name = "Elasticsearch change alert on the number of search fetches currently running"

	/*query = <<EOQ
	pct_change(avg (last_10m),last_10m):
		avg:elasticsearch.search.fetch.current${module.filter-tags.query_alert} by {cluster_name}
	>= 100
EOQ*/

	program_text = <<-EOF
		signal = data('gauge.indices.search.fetch-current', filter=filter('plugin', 'elasticsearch')).mean(by=['cluster_name']).mean(over='10m')
		detect(when(signal >= 100)).publish('CRIT')
	EOF

	rule {
		description = "Average >= 100 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Field Data Evictions
#
resource "signalfx_detector" "field_data_evictions_change" {
	name = "Elasticsearch change alert on the total number of evictions from the fielddata cache"

	program_text = <<-EOF
		signal = data('counter.indices.primaries.fielddata.evictions', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name']).rateofchange().mean(over='15m')
		detect(when(signal > 120)).publish('CRIT')
	EOF

	rule {
		description = "Average > 120 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Query Cache Evictions
#
resource "signalfx_detector" "query_cache_evictions_change" {
	name = "Elasticsearch change alert on the number of query cache evictions"

	program_text = <<-EOF
		signal = data('indices.query-cache.evictions', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name']).rateofchange().mean(over='15m')
		detect(when(signal > 120)).publish('CRIT')
	EOF

	rule {
		description = "Average > 120 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Request Cache Evictions
#
resource "signalfx_detector" "request_cache_evictions_change" {
	name = "Elasticsearch change alert on the number of request cache evictions"

	program_text = <<-EOF
		signal = data('indices.request-cache.evictions', filter=filter('plugin', 'elasticsearch')).mean(by=['node_name']).rateofchange().mean(over='15m')
		detect(when(signal > 120)).publish('CRIT')
	EOF

	rule {
		description = "Average > 120 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Task Time in Queue
#
resource "signalfx_detector" "task_time_in_queue_change" {
	name = "Elasticsearch change alert on the average time spent by tasks in the queue"

	program_text = <<-EOF
		signal = data('gauge.cluster.pending-tasks', filter=filter('plugin', 'elasticsearch')).mean(by=['cluster_name']).rateofchange().mean(over='10m')
		detect(when(signal > 200)).publish('CRIT')
	EOF

	rule {
		description = "Average > 200 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
