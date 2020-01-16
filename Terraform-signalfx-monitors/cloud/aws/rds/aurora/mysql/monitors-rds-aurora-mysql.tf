### RDS Aurora Mysql Replica Lag monitor ###
resource "signalfx_detector" "rds_aurora_mysql_replica_lag" {
	name = "RDS Aurora Mysql replica lag"

	program_text = <<-EOF
		signal = data('AuroraReplicaLag', filter=filter('namespace', 'AWS/RDS')).mean(by=['aws_region']).min(over='5m')
		detect(when(signal > 200)).publish('CRIT')
	EOF

	rule {
		description = "Min > 200 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
