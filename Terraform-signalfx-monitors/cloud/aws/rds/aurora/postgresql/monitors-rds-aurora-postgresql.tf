### RDS Aurora Postgresql Replica Lag monitor ###
resource "signalfx_monitor" "rds_aurora_postgresql_replica_lag" {
  count   = var.aurora_replicalag_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] RDS Aurora PostgreSQL replica lag {{#is_alert}}{{{comparator}}} {{threshold}} ms ({{value}}ms){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ms ({{value}}ms){{/is_warning}}"

  /*query = <<EOQ
  ${var.aurora_replicalag_time_aggregator}(${var.aurora_replicalag_timeframe}): (
    avg:aws.rds.rdsto_aurora_postgre_sqlreplica_lag${module.filter-tags.query_alert} by {region,name}
  ) > ${var.aurora_replicalag_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      /* Need to find equivalent rdsto_aurora_postgre_sqlreplica_lag metrics */
      signal = data('XXXXX', filter=filter('namespace', 'AWS/RDS'), rollup='mean').${var.aurora_replicalag_time_aggregator}.mean(by=['aws_region','aws_account_id', 'DBInstanceIdentifier'])
			
			detect(when(signal > ${var.aurora_replicalag_threshold_critical}, ${var.aurora_replicalag_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.aurora_replicalag_message, var.message)
		severity = "Critical"
	}

}
