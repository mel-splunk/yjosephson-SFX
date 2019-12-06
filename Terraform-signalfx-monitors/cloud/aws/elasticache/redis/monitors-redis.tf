resource "signalfx_monitor" "redis_cache_hits" {
  count   = var.cache_hits_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache redis cache hit ratio {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.cache_hits_time_aggregator}(${var.cache_hits_timeframe}): default(
      avg:aws.elasticache.cache_hits${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}.as_rate() / (
        avg:aws.elasticache.cache_hits${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}.as_rate() +
        avg:aws.elasticache.cache_misses${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}.as_rate())
    * 100, 100) < ${var.cache_hits_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('CacheHits', filter=filter('namespace', 'AWS/ElastiCache') and filter('stat', 'mean'), rollup='mean').${var.cache_hits_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			B = data('CacheMisses', filter=filter('namespace', 'AWS/ElastiCache') and filter('stat', 'mean'), rollup='mean').${var.cache_hits_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
      signal = (A/ (A + B)).scale(100)
			detect(when(signal < ${var.cache_hits_threshold_critical}, ('${var.cache_hits_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.cache_hits_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "redis_cpu_high" {
  count   = var.cpu_high_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache redis CPU {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.cpu_high_time_aggregator}(${var.cpu_high_timeframe}): (
      avg:aws.elasticache.engine_cpuutilization${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    ) > ${var.cpu_high_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('EngineCPUUtilization', filter=filter('namespace', 'AWS/ElastiCache') and filter('stat', 'mean'), rollup='mean').${var.cpu_high_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal > ${var.cpu_high_threshold_critical}, ('${var.cpu_high_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.cpu_high_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "redis_replication_lag" {
  count   = var.replication_lag_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache redis replication lag {{#is_alert}}{{{comparator}}} {{threshold}}s ({{value}}s){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}s ({{value}}s){{/is_warning}}"

  /*query = <<EOQ
    ${var.replication_lag_time_aggregator}(${var.replication_lag_timeframe}): (
      avg:aws.elasticache.replication_lag${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    ) > ${var.replication_lag_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('ReplicationLag', filter=filter('namespace', 'AWS/ElastiCache') and filter('stat', 'mean'), rollup='mean').${var.replication_lag_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal > ${var.replication_lag_threshold_critical}, ('${var.replication_lag_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.replication_lag_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "redis_commands" {
  count   = var.commands_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache redis is receiving no commands"

  /*query = <<EOQ
    sum(${var.commands_timeframe}): (
      avg:aws.elasticache.get_type_cmds${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}.as_count() +
      avg:aws.elasticache.set_type_cmds${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}.as_count()
    ) <= 0
  EOQ*/

  program_text = <<-EOF
      A = data('GetTypeCmds', filter=filter('namespace', 'AWS/ElastiCache') and filter('stat', 'mean'), rollup='mean').mean(by=['aws_region','CacheClusterId','CacheNodeId']).count(by=['aws_region','CacheClusterId','CacheNodeId'])
			B = data('SetTypeCmds', filter=filter('namespace', 'AWS/ElastiCache') and filter('stat', 'mean'), rollup='mean').mean(by=['aws_region','CacheClusterId','CacheNodeId']).count(by=['aws_region','CacheClusterId','CacheNodeId'])
			
      signal = A + B
			detect(when(signal <= 0 )).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.commands_message, var.message)
		severity = "Critical"
	}

}
