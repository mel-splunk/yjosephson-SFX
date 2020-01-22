resource "signalfx_detector" "virtualmachine_status" {
	name = "Virtual Machine is unreachable"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.ClassicCompute/virtualMachines')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "virtualmachine_cpu_usage" {
	name = "Virtual Machine CPU usage"

	program_text = <<-EOF
		signal = data('Percentage CPU', filter=filter('resource_type', 'Microsoft.Compute/virtualMachines')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "virtualmachine_credit_cpu_remaining_too_low" {
	name = "Virtual Machine credit CPU"

	program_text = <<-EOF
		A = data('CPU Credits Remaining', filter=filter('resource_type', 'Microsoft.Compute/virtualMachines'), rollup = 'rate').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		B = data('CPU Credits Consumed', filter=filter('resource_type', 'Microsoft.Compute/virtualMachines'), rollup = 'rate').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal < 15)).publish('CRIT')
	EOF

	rule {
		description = "Min < 15 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "virtualmachine_ram_reserved" {
	name = "Virtual Machine RAM reserved"

	/*query = <<EOQ
		${var.ram_reserved_time_aggregator}(${var.ram_reserved_timeframe}):
			avg:azure.vm.memory_committed_bytes${module.filter-tags.query_alert} by {resource_group,region,name} / (
			avg:azure.vm.memory_committed_bytes${module.filter-tags.query_alert} by {resource_group,region,name} +
			avg:azure.vm.memory_available_bytes${module.filter-tags.query_alert} by {resource_group,region,name}) * 100
			> ${var.ram_reserved_threshold_critical}
EOQ

	program_text = <<-EOF
		A = data('XXXX', filter=filter('resource_type', 'Microsoft.Compute/virtualMachines'), rollup = 'rate').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		B = data('XXXX', filter=filter('resource_type', 'Microsoft.Compute/virtualMachines'), rollup = 'rate').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		signal = ((A/(A+B))*100).min(over='15m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "virtualmachine_disk_space" {
	name = "Virtual Machine disk space"

	/*query = <<EOQ
		${var.disk_space_time_aggregator}(${var.disk_space_timeframe}):
		100 - avg:azure.vm.logical_disk_total_pct_free_space${module.filter-tags.query_alert} by {resource_group,region,name}
		> ${var.disk_space_threshold_critical}
EOQ

	program_text = <<-EOF
		A = data('XXXX', filter=filter('resource_type', 'Microsoft.Compute/virtualMachines')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		signal = (100-A).max(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "virtualmachine_requests_failed" {
	name = "Virtual Machine requests failed"

	/*query = <<EOQ
		${var.requests_failed_time_aggregator}(${var.requests_failed_timeframe}):
			default( 
				default(avg:azure.vm.asp.net_applications_total_requests_failed${module.filter-tags.query_alert} by {resource_group,region,name}, 0) /
				default(avg:azure.vm.asp.net_applications_total_requests_total${module.filter-tags.query_alert} by {resource_group,region,name}, 1)
			, 0) * 100
			> ${var.requests_failed_threshold_critical}
EOQ

	program_text = <<-EOF
		A = data('XXXX', filter=filter('resource_type', 'Microsoft.Compute/virtualMachines'), rollup = 'rate').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		B = data('XXXX', filter=filter('resource_type', 'Microsoft.Compute/virtualMachines'), rollup = 'rate').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		signal = ((A/B)*100).min(over='10m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}
