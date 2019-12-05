resource "signalfx_monitor" "elasticache_eviction" {
  count   = var.eviction_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache eviction {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}"

  /*query = <<EOQ
    sum(${var.eviction_timeframe}): (
      avg:aws.elasticache.evictions${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    ) > ${var.eviction_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('Evictions', filter=filter('namespace', 'AWS/ElastiCache'), rollup='mean').mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal > ${var.eviction_threshold_critical}, sum('${var.eviction_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.eviction_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "elasticache_max_connection" {
  count   = var.max_connection_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache max connections reached {{#is_alert}}{{{comparator}}} {{threshold}} {{/is_alert}}"

  /*query = <<EOQ
    ${var.max_connection_time_aggregator}(${var.max_connection_timeframe}): (
      avg:aws.elasticache.curr_connections${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    ) >= 65000
  EOQ*/

  program_text = <<-EOF
      signal = data('CurrConnections', filter=filter('namespace', 'AWS/ElastiCache'), rollup='mean').${var.max_connection_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal > 65000)).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.max_connection_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "elasticache_no_connection" {
  count   = var.no_connection_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache connections {{#is_alert}}{{{comparator}}} {{threshold}} {{/is_alert}}"

  /*query = <<EOQ
    ${var.no_connection_time_aggregator}(${var.no_connection_timeframe}): (
      avg:aws.elasticache.curr_connections${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    ) <= 0
  EOQ*/

  program_text = <<-EOF
      signal = data('CurrConnections', filter=filter('namespace', 'AWS/ElastiCache'), rollup='mean').${var.no_connection_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal <= 0)).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.no_connection_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "elasticache_swap" {
  count   = var.swap_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache swap {{#is_alert}}{{{comparator}}} {{threshold}}MB ({{value}}MB){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}MB ({{value}}MB){{/is_warning}}"

  /*query = <<EOQ
    ${var.swap_time_aggregator}(${var.swap_timeframe}): (
      avg:aws.elasticache.swap_usage${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    ) > ${var.swap_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('SwapUsage', filter=filter('namespace', 'AWS/ElastiCache'), rollup='mean').${var.swap_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal > ${var.swap_threshold_critical}, max('${var.swap_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.swap_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "elasticache_free_memory" {
  count   = var.free_memory_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache free memory {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    pct_change(avg(${var.free_memory_timeframe}),${var.free_memory_condition_timeframe}):
      avg:aws.elasticache.freeable_memory${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    < ${var.free_memory_threshold_critical}
  EOQ*/

  program_text = <<-EOF
    /* Need to figure out what pct_change is */
      signal = data('FreeableMemory', filter=filter('namespace', 'AWS/ElastiCache'), rollup='mean').${var.free_memory_condition_timeframe}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal < ${var.free_memory_threshold_critical}, max('${var.free_memory_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.free_memory_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "elasticache_eviction_growing" {
  count   = var.eviction_growing_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache evictions is growing {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
    pct_change(avg(${var.eviction_growing_timeframe}),${var.eviction_growing_condition_timeframe}):
      avg:aws.elasticache.evictions${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    > ${var.eviction_growing_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('Evictions', filter=filter('namespace', 'AWS/ElastiCache'), rollup='mean').${var.eviction_growing_condition_timeframe}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal > ${var.eviction_growing_threshold_critical}, max('${var.eviction_growing_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.eviction_growing_message, var.message)
		severity = "Critical"
	}

}
