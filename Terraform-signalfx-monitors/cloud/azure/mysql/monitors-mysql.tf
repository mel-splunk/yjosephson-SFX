resource "signalfx_detector" "mysql_cpu_usage" {
	name = "Mysql Server CPU usage"

	program_text = <<-EOF
		signal = data('cpu_percent', filter=filter('resource_type', 'Microsoft.DBforMySQL/servers)).mean(by=['resource_group_id', 'region', 'name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "mysql_free_storage" {
	name = "Mysql Server storage"

	program_text = <<-EOF
		A = data('storage_percent', filter=filter('resource_type', 'Microsoft.DBforMySQL/servers)).mean(by=['resource_group_id', 'region', 'name'])
		signal = (100-A).min(over='15m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Min < 10 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "mysql_io_consumption" {
	name = "Mysql Server IO consumption"

	program_text = <<-EOF
		signal = data('io_consumption_percent', filter=filter('resource_type', 'Microsoft.DBforMySQL/servers)).mean(by=['resource_group_id', 'region', 'name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "mysql_memory_usage" {
	name = "Mysql Server memory usage"

	program_text = <<-EOF
		signal = data('memory_percent', filter=filter('resource_type', 'Microsoft.DBforMySQL/servers)).mean(by=['resource_group_id', 'region', 'name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
