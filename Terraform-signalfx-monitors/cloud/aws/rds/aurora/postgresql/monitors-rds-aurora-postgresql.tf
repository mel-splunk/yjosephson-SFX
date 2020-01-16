### RDS Aurora Postgresql Replica Lag monitor ###
resource "signalfx_detector" "rds_aurora_postgresql_replica_lag" {
	name = "RDS Aurora PostgreSQL replica lag"

	program_text = <<-EOF
		signal = data('RDSToAuroraPostgreSQLReplicaLag', filter=filter('namespace', 'AWS/RDS')).mean(by=['aws_region']).min(over='5m')
		detect(when(signal > 200)).publish('CRIT')
	EOF

	rule {
		description = "Min > 200 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
