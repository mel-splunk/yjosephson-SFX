resource "signalfx_monitor" "memcached_get_hits" {
  count   = var.get_hits_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache memcached cache hit ratio {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*(query = <<EOQ
    ${var.get_hits_time_aggregator}(${var.get_hits_timeframe}): (
      default(avg:aws.elasticache.get_hits${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}.as_rate(), 0) / (
        default(avg:aws.elasticache.get_hits${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}.as_rate(), 0) +
        default(avg:aws.elasticache.get_misses${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}.as_rate(), 0))
    ) * 100 < ${var.get_hits_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('*Hits', filter=filter('namespace', 'AWS/ElastiCache') and filter('CacheClusterId', '*') and filter('stat', 'mean') and (not filter('CacheNodeId', '*')) and filter('aws_region', '*'), rollup='mean').${var.get_hits_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			B = data('*Misses', filter=filter('namespace', 'AWS/ElastiCache') and filter('CacheClusterId', '*') and filter('stat', 'mean') and (not filter('CacheNodeId', '*')) and filter('aws_region', '*'), rollup='mean').${var.get_hits_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
      signal = (A/ (A+B)).scale(100)
			detect(when(signal < ${var.get_hits_threshold_critical}, ('${var.eviction_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.get_hits_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "memcached_cpu_high" {
  count   = var.cpu_high_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Elasticache memcached CPU {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.cpu_high_time_aggregator}(${var.cpu_high_timeframe}): (
      avg:aws.elasticache.cpuutilization${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    ) > ${var.cpu_high_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('CPUUtilization', filter=filter('namespace', 'AWS/ElastiCache') and filter('CacheNodeId', '*') and filter('stat', 'mean') and filter('CacheClusterId', '*'), rollup='mean').${var.cpu_high_time_aggregator}.mean(by=['aws_region','CacheClusterId','CacheNodeId'])
			
			detect(when(signal > ${var.cpu_high_threshold_critical}, ('${var.cpu_high_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.cpu_high_message, var.message)
		severity = "Critical"
	}

}

