resource "signalfx_detector" "status" {
	name = "SQL Database is down"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.Sql/servers/databases')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).max(over='5m')
		detect(when(signal != 1)).publish('CRIT')
	EOF

	rule {
		description = "Max != 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "sql-database_cpu" {
	name = "SQL Database CPU too high"

	program_text = <<-EOF
		signal = data('cpu_percent', filter=filter('resource_type', 'Microsoft.Sql/servers/databases')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "sql-database_free_space_low" {
	name = "SQL Database high disk usage"

	program_text = <<-EOF
		signal = data('storage_percent', filter=filter('resource_type', 'Microsoft.Sql/servers/databases')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).max(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Max > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "sql-database_dtu_consumption_high" {
	name = "SQL Database DTU Consumption too high"

	program_text = <<-EOF
		signal = data('dtu_consumption_percent', filter=filter('resource_type', 'Microsoft.Sql/servers/databases')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).mean(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "sql-database_deadlocks_count" {
	name = "SQL Database Deadlocks too high"

	program_text = <<-EOF
		signal = data('deadlock', filter=filter('resource_type', 'Microsoft.Sql/servers/databases'), rollup='sum').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).sum(over='5m')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
