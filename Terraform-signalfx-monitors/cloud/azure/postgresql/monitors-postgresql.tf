resource "signalfx_detector" "postgresql_cpu_usage" {
	name = "Postgresql Server CPU usage"

	program_text = <<-EOF
		signal = data('cpu_percent', filter=filter('resource_type', 'Microsoft.DBforPostgreSQL/servers')).mean(by=['resource_group_id', 'region', 'name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "postgresql_no_connection" {
	name = "Postgresql Server has no connection"

	program_text = <<-EOF
		signal = data('active_connections', filter=filter('resource_type', 'Microsoft.DBforPostgreSQL/servers')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Min < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "postgresql_free_storage" {
	name = "Postgresql Server storage"

	program_text = <<-EOF
		A = data('storage_percent', filter=filter('resource_type', 'Microsoft.DBforPostgreSQL/servers')).mean(by=['resource_group_id', 'region', 'name'])
		signal = (100-A).min(over='15m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Min < 10 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "postgresql_io_consumption" {
	name = "Postgresql Server IO consumption"

	program_text = <<-EOF
		signal = data('io_consumption_percent', filter=filter('resource_type', 'Microsoft.DBforPostgreSQL/servers')).mean(by=['resource_group_id', 'region', 'name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "postgresql_memory_usage" {
	name = "Postgresql Server memory usage "

	program_text = <<-EOF
		signal = data('memory_percent', filter=filter('resource_type', 'Microsoft.DBforPostgreSQL/servers')).mean(by=['resource_group_id', 'region', 'name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
