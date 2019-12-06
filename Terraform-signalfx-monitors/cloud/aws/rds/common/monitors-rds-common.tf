### RDS instance CPU monitor ###
resource "signalfx_monitor" "rds_cpu_90_15min" {
  count   = var.cpu_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] RDS instance CPU high {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.cpu_time_aggregator}(${var.cpu_timeframe}): (
      avg:aws.rds.cpuutilization${module.filter-tags.query_alert} by {region,name}
    ) > ${var.cpu_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('CPUUtilization', filter=filter('namespace', 'AWS/RDS'), rollup='mean').${var.cpu_time_aggregator}.mean(by=['aws_region','aws_account_id', 'DBInstanceIdentifier'])
			
			detect(when(signal > ${var.cpu_threshold_critical}, ${var.cpu_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.cpu_message, var.message)
		severity = "Critical"
	}

}

### RDS instance free space monitor ###
resource "signalfx_monitor" "rds_free_space_low" {
  count   = var.diskspace_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] RDS instance free space {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
  ${var.diskspace_time_aggregator}(${var.diskspace_timeframe}): (
    avg:aws.rds.free_storage_space${module.filter-tags.query_alert} by {region,name} /
    avg:aws.rds.total_storage_space${module.filter-tags.query_alert} by {region,name} * 100
  ) < ${var.diskspace_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      /* Need to figure out total_storage_space */
      A = data('FreeStorageSpace', filter=filter('namespace', 'AWS/RDS'), rollup='mean').${var.diskspace_time_aggregator}.mean(by=['aws_region','aws_account_id', 'DBInstanceIdentifier'])
			
      signal = (A).scale(100)
			detect(when(signal < ${var.diskspace_threshold_critical}, ${var.diskspace_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.diskspace_message, var.message)
		severity = "Critical"
	}

}

### RDS Replica Lag monitor ###
resource "signalfx_monitor" "rds_replica_lag" {
  count   = var.replicalag_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] RDS replica lag {{#is_alert}}{{{comparator}}} {{threshold}} ms ({{value}}ms){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ms ({{value}}ms){{/is_warning}}"

  /*query = <<EOQ
  ${var.replicalag_time_aggregator}(${var.replicalag_timeframe}): (
    avg:aws.rds.replica_lag${module.filter-tags.query_alert} by {region,name}
  ) > ${var.replicalag_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('ReplicaLag', filter=filter('namespace', 'AWS/RDS'), rollup='mean').${var.replicalag_time_aggregator}.mean(by=['aws_region','aws_account_id', 'DBInstanceIdentifier'])
			
			detect(when(signal > ${var.replicalag_threshold_critical}, ${var.replicalag_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.replicalag_message, var.message)
		severity = "Critical"
	}

}
