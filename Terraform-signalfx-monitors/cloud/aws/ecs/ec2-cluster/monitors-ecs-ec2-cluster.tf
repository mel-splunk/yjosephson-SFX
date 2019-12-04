# Monitors related to ECS Cluster
resource "signalfx_monitor" "ecs_agent_status" {
  count   = var.agent_status_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ECS Agent disconnected {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    "aws.ecs.agent_connected"${module.filter-tags.service_check}.by("cluster","instance_id").last(6).count_by_status()
  EOQ*/

  /* Not sure the equivalent metrics for this yet */
  program_text = <<-EOF
      signal = data('XXXX')
			
			detect(when(signal > ${var.agent_status_threshold_critical}, max('${var.agent_status_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.agent_status_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "cluster_cpu_utilization" {
  count   = var.cluster_cpu_utilization_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ECS Cluster CPU Utilization High {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.cluster_cpu_utilization_time_aggregator}(${var.cluster_cpu_utilization_timeframe}):
      avg:aws.ecs.cluster.cpuutilization${module.filter-tags.query_alert} by {region,clustername}
    > ${var.cluster_cpu_utilization_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('CPUUtilization', filter=filter('ecs_task_group', '*'), rollup='mean').${var.cluster_cpu_utilization_time_aggregator}.mean(by=['aws_region','ClusterName'])
			
			detect(when(signal > ${var.cluster_cpu_utilization_threshold_critical}, max('${var.cluster_cpu_utilization_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.cluster_cpu_utilization_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "cluster_memory_reservation" {
  count   = var.cluster_memory_reservation_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ECS Cluster Memory Reservation High {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.cluster_memory_reservation_time_aggregator}(${var.cluster_memory_reservation_timeframe}):
      avg:aws.ecs.cluster.memory_reservation${module.filter-tags.query_alert} by {region,clustername}
    > ${var.cluster_memory_reservation_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('MemoryReservation', filter=filter('ecs_task_group', '*'), rollup='mean').${var.cluster_memory_reservation_time_aggregator}.mean(by=['aws_region','ClusterName'])
			
			detect(when(signal > ${var.cluster_memory_reservation_threshold_critical}, max('${var.cluster_memory_reservation_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.cluster_memory_reservation_message, var.message)
		severity = "Critical"
	}

}
