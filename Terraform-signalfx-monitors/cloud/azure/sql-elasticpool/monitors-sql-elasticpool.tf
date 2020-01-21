resource "signalfx_detector" "sql_elasticpool_cpu" {
	name = "SQL Elastic Pool CPU too high"

	program_text = <<-EOF
		signal = data('cpu_percent', filter=filter('resource_type', 'Microsoft.Sql/servers/elasticPools')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "sql_elasticpool_free_space_low" {
	name = "SQL Elastic Pool high disk usage"

	program_text = <<-EOF
		signal = data('storage_percent', filter=filter('resource_type', 'Microsoft.Sql/servers/elasticPools')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).max(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Max > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "sql_elasticpool_dtu_consumption_high" {
	name = "SQL Elastic Pool DTU Consumption too high"

	program_text = <<-EOF
		signal = data('dtu_consumption_percent', filter=filter('resource_type', 'Microsoft.Sql/servers/elasticPools')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).mean(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
