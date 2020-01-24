resource "signalfx_detector" "mysql_availability" {
	name = "Mysql server does not respond"

	/*query = <<EOQ
		"mysql.can_connect"${module.filter-tags.service_check}.by("port","server").last(6).count_by_status()
EOQ

	program_text = <<-EOF
		signal = data('XXX'))
		detect(when(signal >= 0)).publish('CRIT')
	EOF

	rule {
		description = "Max >= 2 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "mysql_connection" {
	name = "Mysql Connections limit"

	/*query = <<EOQ
		${var.mysql_connection_time_aggregator}(${var.mysql_connection_timeframe}): (
			avg:mysql.net.connections${module.filter-tags.query_alert} by {server} /
			avg:mysql.net.max_connections_available${module.filter-tags.query_alert} by {server}
		) * 100 > ${var.mysql_connection_threshold_critical}
EOQ

	program_text = <<-EOF
		A = data('XXX', filter=filter('plugin', 'mysql')).mean(by=['server'])
		B = data('XXX', filter=filter('plugin', 'mysql')).mean(by=['server'])
		signal = (A / B).scale(100).mean(over='10m')
		detect(when(signal > 80)).publish('CRIT')
	EOF

	rule {
		description = "Average > 80 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "mysql_aborted" {
	name = "Mysql Aborted connects"

	/*program_text = <<-EOF
		A = data('XXX', filter=filter('plugin', 'mysql')).mean(by=['server'])
		B = data('threads.connected', filter=filter('plugin', 'mysql')).mean(by=['server'])
		signal = (A/B).scale(100).mean(over='10m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Average > 10 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "mysql_slow" {
	name = "Mysql Slow queries"

	program_text = <<-EOF
		A = data('mysql_slow_queries', filter=filter('plugin', 'mysql')).mean(by=['server'])
		B = data('cache_size.qcache', filter=filter('plugin', 'mysql')).mean(by=['server'])
		signal = (A/B).scale(100).mean(over='15m')
		detect(when(signal > 20)).publish('CRIT')
	EOF

	rule {
		description = "Average > 20 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "mysql_pool_efficiency" {
	name = "Mysql Innodb buffer pool efficiency"

	/*query = <<EOQ
		${var.mysql_pool_efficiency_time_aggregator}(${var.mysql_pool_efficiency_timeframe}): (
			avg:mysql.innodb.buffer_pool_reads${module.filter-tags.query_alert} by {server} /
			avg:mysql.innodb.buffer_pool_read_requests${module.filter-tags.query_alert} by {server}
		) * 100 > ${var.mysql_pool_efficiency_threshold_critical}
EOQ

	program_text = <<-EOF
		A = data('XXXX', filter=filter('plugin', 'mysql')).mean(by=['server'])
		B = data('XXXX', filter=filter('plugin', 'mysql')).mean(by=['server'])
		signal = (A/B).scale(100).min(over='1h')
		detect(when(signal > 30)).publish('CRIT')
	EOF

	rule {
		description = "Min > 30 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "mysql_pool_utilization" {
	name = "Mysql Innodb buffer pool utilization"

/*	query = <<EOQ
		${var.mysql_pool_utilization_time_aggregator}(${var.mysql_pool_utilization_timeframe}):
			( avg:mysql.innodb.buffer_pool_total${module.filter-tags.query_alert} by {server} -
			avg:mysql.innodb.buffer_pool_free${module.filter-tags.query_alert} by {server} ) /
			avg:mysql.innodb.buffer_pool_total${module.filter-tags.query_alert} by {server}
		* 100 > ${var.mysql_pool_utilization_threshold_critical}
EOQ

	program_text = <<-EOF
		A = data('XXXX', filter=filter('plugin', 'mysql')).mean(by=['server'])
		B = data('XXXX', filter=filter('plugin', 'mysql')).mean(by=['server'])
		signal = ((A-B)/A).scale(100).min(over='1h')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 1h"
		severity = "Critical"
		detect_labe*/l = "CRIT"
	}
}

resource "signalfx_detector" "mysql_threads_anomaly" {
	name = "Mysql threads changed abnormally"

	/*query = <<EOQ
		${var.mysql_threads_time_aggregator}(${var.mysql_threads_timeframe}):
			anomalies(
				avg:mysql.performance.threads_running${module.filter-tags.query_alert} by {server},
				'${var.mysql_threads_detection_algorithm}',
				${var.mysql_threads_deviations},
				direction='${var.mysql_threads_direction}',
				alert_window='${var.mysql_threads_alert_window}',
				interval=${var.mysql_threads_interval},
				count_default_zero='${var.mysql_threads_count_default_zero}'
				${var.mysql_threads_seasonality == "agile" ? format(",seasonality='%s'", var.mysql_threads_seasonality) : ""}
			)
		>= ${var.mysql_threads_threshold_critical}
EOQ

	program_text = <<-EOF
		signal = data('XXXX', filter=filter('plugin', 'mysql')).mean(by=['server']).mean(over='4h')
		detect(when(signal >= 1)).publish('CRIT')
	EOF

	rule {
		description = "Average >= 1 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "mysql_questions_anomaly" {
	name = "Mysql queries changed abnormally"

	/*query = <<EOQ
		${var.mysql_questions_time_aggregator}(${var.mysql_questions_timeframe}):
			anomalies(
				avg:mysql.performance.questions${module.filter-tags.query_alert} by {server},
				'${var.mysql_questions_detection_algorithm}',
				${var.mysql_questions_deviations},
				direction='${var.mysql_questions_direction}',
				alert_window='${var.mysql_questions_alert_window}',
				interval=${var.mysql_questions_interval},
				count_default_zero='${var.mysql_questions_count_default_zero}'
				${var.mysql_questions_detection_algorithm == "agile" ? format(",seasonality='%s'", var.mysql_questions_seasonality) : ""}
			)
		>= ${var.mysql_questions_threshold_critical}
EOQ

	program_text = <<-EOF
		signal = data('XXXX', filter=filter('plugin', 'mysql')).mean(by=['server']).mean(over='4h')
		detect(when(signal >= 1)).publish('CRIT')
	EOF

	rule {
		description = "Min > 30 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}
