resource "signalfx_detector" "too_many_jobs_failed" {
	name = "IOT Hub Too many jobs failed"

	program_text = <<-EOF
		A = data('jobs.failed', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('jobs.completed', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "too_many_list_jobs_failed" {
	name = "IOT Hub Too many list_jobs failure"

	program_text = <<-EOF
		A = data('jobs.listJobs.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('jobs.listJobs.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "too_many_query_jobs_failed" {
	name = "IOT Hub Too many query_jobs failed"

	program_text = <<-EOF
		A = data('jobs.queryJobs.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('jobs.queryJobs.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "status" {
	name = "IOT Hub is down"

	/*query = <<EOQ
		${var.status_time_aggregator}(${var.status_timeframe}): (
			avg:azure.devices_iothubs.status${module.filter-tags.query_alert} by {resource_group,region,name}
		) < 1
EOQ*/

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.Devices/IotHubs')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "total_devices" {
	name = "IOT Hub Total devices is wrong"

	program_text = <<-EOF
		signal = data('totalDeviceCount', filter=filter('resource_type', 'Microsoft.Devices/IotHubs')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal == 0)).publish('CRIT')
	EOF

	rule {
		description = "Average = 0 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "too_many_c2d_methods_failed" {
	name = "IOT Hub Too many c2d methods failure"

	program_text = <<-EOF
		A = data('c2d.methods.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('c2d.methods.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "too_many_c2d_twin_read_failed" {
	name = "IOT Hub Too many c2d twin read failure"

	program_text = <<-EOF
		A = data('c2d.twin.read.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('c2d.twin.read.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "too_many_c2d_twin_update_failed" {
	name = "IOT Hub Too many c2d twin update failure"

	program_text = <<-EOF
		A = data('c2d.twin.update.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('c2d.twin.update.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "too_many_d2c_twin_read_failed" {
	name = "IOT Hub Too many d2c twin read failure"

	program_text = <<-EOF
		A = data('d2c.twin.read.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('d2c.twin.read.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "too_many_d2c_twin_update_failed" {
	name = "IOT Hub Too many d2c twin update failure"

	program_text = <<-EOF
		A = data('d2c.twin.update.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('d2c.twin.update.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "too_many_d2c_telemetry_egress_dropped" {
	name = "IOT Hub Too many d2c telemetry egress dropped"

	program_text = <<-EOF
		A = data('d2c.telemetry.egress.dropped', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('d2c.telemetry.egress.orphaned', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		C = data('d2c.telemetry.egress.invalid', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		D = data('d2c.telemetry.egress.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B+C+D))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
	}
}

resource "signalfx_detector" "too_many_d2c_telemetry_egress_orphaned" {
	name = "IOT Hub Too many d2c telemetry egress orphaned"

	program_text = <<-EOF
		A = data('d2c.telemetry.egress.orphaned', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('d2c.telemetry.egress.dropped', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		C = data('d2c.telemetry.egress.invalid', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		D = data('d2c.telemetry.egress.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B+C+D))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
	}
}

resource "signalfx_detector" "too_many_d2c_telemetry_egress_invalid" {
	name = "IOT Hub Too many d2c telemetry egress invalid"

	program_text = <<-EOF
		A = data('d2c.telemetry.egress.invalid', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('d2c.telemetry.egress.dropped', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		C = data('d2c.telemetry.egress.orphaned', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		D = data('d2c.telemetry.egress.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B+C+D))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
	}
}

resource "signalfx_detector" "too_many_d2c_telemetry_ingress_nosent" {
	name = "IOT Hub Too many d2c telemetry ingress not sent"

	program_text = <<-EOF
		A = data('d2c.telemetry.ingress.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('d2c.telemetry.ingress.allProtocol', filter=filter('resource_type', 'Microsoft.Devices/IotHubs'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/B)*100).mean(over='5m')
		detect(when(signal > 20)).publish('CRIT')
	EOF

	rule {
		description = "Average > 20 for last 5m"
		severity = "Critical"
	}
}
