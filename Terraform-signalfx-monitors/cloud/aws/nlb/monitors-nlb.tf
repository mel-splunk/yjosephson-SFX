resource "signalfx_monitor" "NLB_no_healthy_instances" {
  count   = var.nlb_no_healthy_instances_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] NLB healthy instances {{#is_alert}}is at 0{{/is_alert}}{{#is_warning}}is at {{value}}%%{{/is_warning}}"

  /*query = <<EOQ
    ${var.nlb_no_healthy_instances_time_aggregator}(${var.nlb_no_healthy_instances_timeframe}): (
      sum:aws.networkelb.healthy_host_count.minimum${module.filter-tags.query_alert} by {region,loadbalancer} / (
      sum:aws.networkelb.healthy_host_count.minimum${module.filter-tags.query_alert} by {region,loadbalancer} +
      sum:aws.networkelb.un_healthy_host_count.maximum${module.filter-tags.query_alert} by {region,loadbalancer} )
    ) * 100 < 1
  EOQ*/

  program_text = <<-EOF
      A = data('HealthyHostCount', filter=filter('namespace', 'AWS/NetworkELB'), rollup='sum').${var.nlb_no_healthy_instances_time_aggregator}.sum(by=['aws_region','LoadBalancerName'])
			B = data('UnHealthyHostCount', filter=filter('namespace', 'AWS/NetworkELB'), rollup='sum').${var.nlb_no_healthy_instances_time_aggregator}.sum(by=['aws_region','LoadBalancerName'])
			
      signal = (A / (A+B)).scale(100)
			detect(when(signal < 1 ${var.nlb_no_healthy_instances_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.nlb_no_healthy_instances_message, var.message)
		severity = "Critical"
	}

}
