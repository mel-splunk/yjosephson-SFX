resource "signalfx_monitor" "ELB_no_healthy_instances" {
  count   = var.elb_no_healthy_instance_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ELB healthy instances {{#is_alert}}is at 0{{/is_alert}}{{#is_warning}}is at {{value}}%%{{/is_warning}}"

  /*query = <<EOQ
    ${var.elb_no_healthy_instance_time_aggregator}(${var.elb_no_healthy_instance_timeframe}): (
      sum:aws.elb.healthy_host_count.minimum${module.filter-tags.query_alert} by {region,loadbalancername} / (
      sum:aws.elb.healthy_host_count.minimum${module.filter-tags.query_alert} by {region,loadbalancername} +
      sum:aws.elb.un_healthy_host_count.maximum${module.filter-tags.query_alert} by {region,loadbalancername} )
    ) * 100 < 1
  EOQ*/

  program_text = <<-EOF
      A = data('HealthyHostCount', filter=filter('namespace', 'AWS/ELB'), rollup='sum').${var.elb_no_healthy_instance_time_aggregator}.sum(by=['aws_region','LoadBalancerName'])
			B = data('UnHealthyHostCount', filter=filter('namespace', 'AWS/ELB'), rollup='sum').${var.elb_no_healthy_instance_time_aggregator}.sum(by=['aws_region','LoadBalancerName'])
			
      signal = (A/ (A + B)).scale(100)
			detect(when(signal < 1, ('${var.elb_no_healthy_instance_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.elb_no_healthy_instance_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "ELB_too_much_4xx" {
  count   = var.elb_4xx_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ELB 4xx errors too high {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    sum(${var.elb_4xx_timeframe}):
      default(avg:aws.elb.httpcode_elb_4xx${module.filter-tags.query_alert} by {region,loadbalancername}.as_rate(), 0) / (
      default(avg:aws.elb.request_count${module.filter-tags.query_alert} by {region,loadbalancername}.as_rate() + ${var.artificial_requests_count}, 1))
      * 100 > ${var.elb_4xx_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('HTTPCode_ELB_4XX', filter=filter('namespace', 'AWS/ELB'), rollup='mean').sum(by=['aws_region','LoadBalancerName'])
			B = data('RequestCount', filter=filter('namespace', 'AWS/ELB'), rollup='mean').sum(by=['aws_region','LoadBalancerName'])
			
      signal = (A/ (B + ${var.artificial_requests_count})).scale(100)
			detect(when(signal > ${var.elb_4xx_threshold_critical}, sum('${var.elb_4xx_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.elb_4xx_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "ELB_too_much_5xx" {
  count   = var.elb_5xx_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ELB 5xx errors too high {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    sum(${var.elb_5xx_timeframe}):
      default(avg:aws.elb.httpcode_elb_5xx${module.filter-tags.query_alert} by {region,loadbalancername}.as_rate(), 0) / (
      default(avg:aws.elb.request_count${module.filter-tags.query_alert} by {region,loadbalancername}.as_rate() + ${var.artificial_requests_count}, 1))
      * 100 > ${var.elb_5xx_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('HTTPCode_ELB_5XX', filter=filter('namespace', 'AWS/ELB'), rollup='mean').sum(by=['aws_region','LoadBalancerName'])
			B = data('RequestCount', filter=filter('namespace', 'AWS/ELB'), rollup='mean').sum(by=['aws_region','LoadBalancerName'])
			
      signal = (A/ (B + ${var.artificial_requests_count})).scale(100)
			detect(when(signal > ${var.elb_5xx_threshold_critical}, sum('${var.elb_5xx_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.elb_5xx_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "ELB_too_much_4xx_backend" {
  count   = var.elb_backend_4xx_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ELB backend 4xx errors too high {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    sum(${var.elb_backend_4xx_timeframe}):
      default(avg:aws.elb.httpcode_backend_4xx${module.filter-tags.query_alert} by {region,loadbalancername}.as_rate(), 0) / (
      default(avg:aws.elb.request_count${module.filter-tags.query_alert} by {region,loadbalancername}.as_rate() + ${var.artificial_requests_count}, 1))
      * 100 > ${var.elb_backend_4xx_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('HTTPCode_Backend_4XX', filter=filter('namespace', 'AWS/ELB'), rollup='mean').sum(by=['aws_region','LoadBalancerName'])
			B = data('RequestCount', filter=filter('namespace', 'AWS/ELB'), rollup='mean').sum(by=['aws_region','LoadBalancerName'])
			
      signal = (A/ (B + ${var.artificial_requests_count})).scale(100)
			detect(when(signal > ${var.elb_backend_4xx_threshold_critical}, sum('${var.elb_backend_4xx_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.elb_backend_4xx_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "ELB_too_much_5xx_backend" {
  count   = var.elb_backend_5xx_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ELB backend 5xx errors too high {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    sum(${var.elb_backend_5xx_timeframe}):
      default(avg:aws.elb.httpcode_backend_5xx${module.filter-tags.query_alert} by {region,loadbalancername}.as_rate(), 0) / (
      default(avg:aws.elb.request_count${module.filter-tags.query_alert} by {region,loadbalancername}.as_rate() + ${var.artificial_requests_count}, 1))
      * 100 > ${var.elb_backend_5xx_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('HTTPCode_Backend_5XX', filter=filter('namespace', 'AWS/ELB'), rollup='mean').sum(by=['aws_region','LoadBalancerName'])
			B = data('RequestCount', filter=filter('namespace', 'AWS/ELB'), rollup='mean').sum(by=['aws_region','LoadBalancerName'])
			
      signal = (A/ (B + ${var.artificial_requests_count})).scale(100)
			detect(when(signal > ${var.elb_backend_5xx_threshold_critical}, sum('${var.elb_backend_5xx_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.elb_backend_5xx_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "ELB_backend_latency" {
  count   = var.elb_backend_latency_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ELB latency too high {{#is_alert}}{{{comparator}}} {{threshold}}s ({{value}}s){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}s ({{value}}s){{/is_warning}}"

  /*query = <<EOQ
    ${var.elb_backend_latency_time_aggregator}(${var.elb_backend_latency_timeframe}):
      default(avg:aws.elb.latency${module.filter-tags.query_alert} by {region,loadbalancername}, 0)
    > ${var.elb_backend_latency_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('Latency', filter=filter('namespace', 'AWS/ELB'), rollup='mean').${var.elb_backend_latency_time_aggregator}.sum(by=['aws_region','LoadBalancerName'])
			
			detect(when(signal > ${var.elb_backend_latency_critical}, ${var.elb_backend_latency_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.elb_backend_latency_message, var.message)
		severity = "Critical"
	}

}
