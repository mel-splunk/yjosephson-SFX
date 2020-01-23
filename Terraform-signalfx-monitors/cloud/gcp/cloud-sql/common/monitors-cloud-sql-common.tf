#
# CPU Utilization
#
resource "signalfx_detector" "cpu_utilization" {
	name = "Cloud SQL CPU Utilization"

	program_text = <<-EOF
		A = data('database/cpu/utilization').mean(by=['database_id'])
		signal = (A*100).mean(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Disk Utilization
#
resource "signalfx_detector" "disk_utilization" {
	name = "Cloud SQL Disk Utilization"

	program_text = <<-EOF
		A = data('database/disk/utilization').mean(by=['database_id'])
		signal = (A*100).mean(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Disk Utilization Forecast
#
resource "signalfx_detector" "disk_utilization_forecast" {
	name = "Cloud SQL Disk Utilization could reach"

	/*query = <<EOQ
	${var.disk_utilization_forecast_time_aggregator}(${var.disk_utilization_forecast_timeframe}):
		forecast(
			avg:gcp.cloudsql.database.disk.utilization{${var.filter_tags}} by {database_id} * 100,
			'${var.disk_utilization_forecast_algorithm}',
			${var.disk_utilization_forecast_deviations},
			interval='${var.disk_utilization_forecast_interval}',
			${var.disk_utilization_forecast_algorithm == "linear" ? format("history='%s',model='%s'", var.disk_utilization_forecast_linear_history, var.disk_utilization_forecast_linear_model) : ""}
			${var.disk_utilization_forecast_algorithm == "seasonal" ? format("seasonality='%s'", var.disk_utilization_forecast_seasonal_seasonality) : ""}
		)
	>= ${var.disk_utilization_forecast_threshold_critical}
EOQ

	program_text = <<-EOF
		A = data('database/disk/utilization').max(by=['database_id'])
		signal = (A*100).max(over='1w')
		detect(when(signal > 80)).publish('CRIT')
	EOF

	rule {
		description = "Average > 80 for next 1w"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

#
# Memory Utilization
#
resource "signalfx_detector" "memory_utilization" {
	name = "Cloud SQL Memory Utilization"

	program_text = <<-EOF
		A = data('database/memory/utilization').mean(by=['database_id'])
		signal = (A*100).mean(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Memory Utilization Forecast
#
resource "signalfx_detector" "memory_utilization_forecast" {
	name = "Cloud SQL Memory Utilization"

	/*query = <<EOQ
	${var.memory_utilization_forecast_time_aggregator}(${var.memory_utilization_forecast_timeframe}):
		forecast(
			avg:gcp.cloudsql.database.memory.utilization{${var.filter_tags}} by {database_id} * 100,
			'${var.memory_utilization_forecast_algorithm}',
			${var.memory_utilization_forecast_deviations},
			interval='${var.memory_utilization_forecast_interval}',
			${var.memory_utilization_forecast_algorithm == "linear" ? format("history='%s',model='%s'", var.memory_utilization_forecast_linear_history, var.memory_utilization_forecast_linear_model) : ""}
			${var.memory_utilization_forecast_algorithm == "seasonal" ? format("seasonality='%s'", var.memory_utilization_forecast_seasonal_seasonality) : ""}
			)
		>= ${var.memory_utilization_forecast_threshold_critical}
EOQ

	program_text = <<-EOF
		A = data('database/memory/utilization').mean(by=['database_id'])
		signal = (A*100).max(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

#
# Failover Unavailable
#
resource "signalfx_detector" "failover_unavailable" {
	name = "Cloud SQL Failover Unavailable"

	program_text = <<-EOF
		signal = data('database/available_for_failover').mean(by=['database_id']).max(over='10m')
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	rule {
		description = "Max <= 0 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
