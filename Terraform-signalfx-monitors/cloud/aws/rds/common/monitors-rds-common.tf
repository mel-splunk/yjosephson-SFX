### RDS instance CPU monitor ###
resource "signalfx_detector" "rds_cpu_90_15min" {
	name = "RDS instance CPU high"

	program_text = <<-EOF
		signal = data('CPUUtilization', filter=filter('namespace', 'AWS/RDS')).mean(by=['aws_region']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

### RDS instance free space monitor ###
resource "signalfx_detector" "rds_free_space_low" {
	name = "RDS instance free space"

	/*query = <<EOQ
	${var.diskspace_time_aggregator}(${var.diskspace_timeframe}): (
		avg:aws.rds.free_storage_space${module.filter-tags.query_alert} by {region,name} /
		avg:aws.rds.total_storage_space${module.filter-tags.query_alert} by {region,name} * 100
	) < 10
	EOQ*/

	program_text = <<-EOF
		A = data('FreeStorageSpace', filter=filter('namespace', 'AWS/RDS')).mean(by=['aws_region'])
		signal = (A).min(over='15m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Min < 10 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

### RDS Replica Lag monitor ###
resource "signalfx_detector" "rds_replica_lag" {
	name = "RDS replica lag"

	program_text = <<-EOF
			signal = data('ReplicaLag', filter=filter('namespace', 'AWS/RDS')).mean(by=['aws_region']).min(over='5m')
			detect(when(signal > 300)).publish('CRIT')
	EOF

	rule {
		description = "Min > 300 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
