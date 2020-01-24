resource "signalfx_detector" "postgresql_availability" {
	name = "max average delay - ${var.clusters[count.index]}"

	/*query = <<EOQ
		"postgres.can_connect"${module.filter-tags.service_check}.by("port","server").last(6).count_by_status()
EOQ*/

}

resource "signalfx_detector" "postgresql_connection_too_high" {
	name = "PostgreSQL Connections"

	/*query = <<EOQ
		${var.postgresql_connection_time_aggregator}(${var.postgresql_connection_timeframe}):
			avg:postgresql.percent_usage_connections${module.filter-tags.query_alert} by {server}
		* 100 > 80
EOQ*/

	program_text = <<-EOF
		A = data('XXXX', filter=filter('plugin', 'postgresql')).mean(by=['server'])
		signal = (A*100).mean(over='15m')
		detect(when(signal > 80)).publish('CRIT')
	EOF

	rule {
		description = "Average > 80 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "postgresql_too_many_locks" {
	name = "PostgreSQL too many locks"

	/*query = <<EOQ
		${var.postgresql_lock_time_aggregator}(${var.postgresql_lock_timeframe}):
			default(avg:postgresql.locks${module.filter-tags.query_alert} by {server}, 0)
		> ${var.postgresql_lock_threshold_critical}
EOQ*/

	program_text = <<-EOF
		signal = data('XXXX', filter=filter('plugin', 'postgresql'), extrapolation='zero').mean(by=['server']).min(over='5m')
		detect(when(signal > 99)).publish('CRIT')
	EOF

	rule {
		description = "Min > 99 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
