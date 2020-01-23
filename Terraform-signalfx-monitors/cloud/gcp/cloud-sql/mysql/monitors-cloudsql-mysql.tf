#
# Replication Lag
#
resource "signalfx_detector" "replication_lag" {
	name = "Cloud SQL MySQL Replication Lag"

	program_text = <<-EOF
		signal = data('database/mysql/replication/seconds_behind_master').mean(by=['database_id']).min(over='10m')
		detect(when(signal > 180)).publish('CRIT')
	EOF

	rule {
		description = "Min > 180 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
