resource "signalfx_detector" "status" {
	name = "Serverfarm is down"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.Web/serverfarms')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal != 1)).publish('CRIT')
	EOF

	rule {
		description = "Max != 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "cpu_percentage" {
	name = "Serverfarm CPU percentage is too high"

	program_text = <<-EOF
		signal = data('CpuPercentage', filter=filter('resource_type', 'Microsoft.Web/serverfarms')).mean(by=['resource_group_id', 'region', 'name']).min(over='10m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "memory_percentage" {
	name = "Serverfarm memory percentage is too high"

	program_text = <<-EOF
		signal = data('MemoryPercentage', filter=filter('resource_type', 'Microsoft.Web/serverfarms')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
