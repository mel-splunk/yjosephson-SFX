# Monitors related to services
resource "signalfx_monitor" "service_cpu_utilization" {
  count   = var.service_cpu_utilization_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ECS Service CPU Utilization High {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.service_cpu_utilization_time_aggregator}(${var.service_cpu_utilization_timeframe}):
      avg:aws.ecs.cpuutilization${module.filter-tags.query_alert} by {region,servicename}
    > ${var.service_cpu_utilization_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('CPUUtilization', filter=filter('namespace', 'AWS/ECS') and filter('stat', 'mean')), rollup='mean').${var.service_cpu_utilization_time_aggregator}.mean(by=['aws_region','ServiceName'])
		  
			detect(when(signal > ${var.pct_errors_threshold_critical}, max('${var.service_cpu_utilization_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.service_cpu_utilization_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "service_memory_utilization" {
  count   = var.service_memory_utilization_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ECS Service Memory Utilization High {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.service_memory_utilization_time_aggregator}(${var.service_memory_utilization_timeframe}):
      avg:aws.ecs.memory_utilization${module.filter-tags.query_alert} by {region,servicename}
    > ${var.service_memory_utilization_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('MemoryUtilization', filter=filter('namespace', 'AWS/ECS') and filter('stat', 'mean')), rollup='mean').${var.service_memory_utilization_time_aggregator}.mean(by=['aws_region','ServiceName'])
		  
			detect(when(signal > ${var.service_memory_utilization_threshold_critical}, max('${var.service_memory_utilization_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.service_memory_utilization_message, var.message)
		severity = "Critical"
	}

}

resource "signalfx_monitor" "service_missing_tasks" {
  count   = var.service_missing_tasks_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ECS Service not healthy enough {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
  ${var.service_missing_tasks_time_aggregator}(${var.service_missing_tasks_timeframe}):
    avg:aws.ecs.service.running{${var.filter_tags}} by {region,servicename} / avg:aws.ecs.service.desired{${var.filter_tags}} by {region,servicename}
  * 100 < ${var.service_missing_tasks_threshold_critical}
  EOQ*/

  program_text = <<-EOF
		  A = data('cpu.usage.system', filter=filter('ecs_task_arn', '*'), rollup='mean').count().${var.service_missing_tasks_time_aggregator}.mean(by=['aws_region','ServiceName'])
      B = data('cpu.usage.system', filter=filter('ecs_task_arn', '*') and filter('AWSUniqueId', '*'), rollup='mean').count().${var.service_missing_tasks_time_aggregator}.mean(by=['aws_region','ServiceName'])
      C = (A-B) /* Number of running containers, still need to figure out service.desired */

      signal = (C).scale(100)
			detect(when(signal < ${var.service_missing_tasks_threshold_critical}, max('${var.service_missing_tasks_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.service_missing_tasks_message, var.message)
		severity = "Critical"
	}

}
