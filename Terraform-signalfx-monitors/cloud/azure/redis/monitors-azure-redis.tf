resource "signalfx_detector" "status" {
	name = "Redis {{name}} is down"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.Cache/redis')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal != 1)).publish('CRIT')
	EOF

	rule {
		description = "Max != 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "evictedkeys" {
	name = "Redis too many evictedkeys"

	program_text = <<-EOF
		signal = data('evictedkeys', filter=filter('resource_type', 'Microsoft.Cache/redis')).mean(by=['resource_group_id', 'region', 'name']).mean(over='5m')
		detect(when(signal > 100)).publish('CRIT')
	EOF

	rule {
		description = "Average > 100 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "percent_processor_time" {
	name = "Redis processor time too high"

	program_text = <<-EOF
		signal = data('percentProcessorTime', filter=filter('resource_type', 'Microsoft.Cache/redis')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal > 80)).publish('CRIT')
	EOF

	rule {
		description = "Min > 80 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "server_load" {
	name = "Redis server load too high"

	program_text = <<-EOF
		signal = data('serverLoad', filter=filter('resource_type', 'Microsoft.Cache/redis')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
