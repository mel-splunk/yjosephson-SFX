resource "signalfx_detector" "servicebus_status" {
	name = "Service Bus is down"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.ServiceBus/namespaces')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal != 1)).publish('CRIT')
	EOF

	rule {
		description = "Max != 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "service_bus_no_active_connections" {
	name = "Service Bus has no active connection"

	program_text = <<-EOF
		signal = data('ActiveConnections', filter=filter('resource_type', 'Microsoft.ServiceBus/namespaces')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "service_bus_user_errors" {
	name = "Service Bus user errors rate is high"

	program_text = <<-EOF
		A = data('UserErrors', filter=filter('resource_type', 'Microsoft.ServiceBus/namespaces'), extrapolation='zero').mean(by=['resource_group_id', 'region', 'name'])
		B = data('IncomingRequests', filter=filter('resource_type', 'Microsoft.ServiceBus/namespaces'), extrapolation='zero').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "service_bus_server_errors" {
	name = "Service Bus server errors rate is high"

	program_text = <<-EOF
		A = data('ServerErrors', filter=filter('resource_type', 'Microsoft.ServiceBus/namespaces'), extrapolation='zero').mean(by=['resource_group_id', 'region', 'name'])
		B = data('IncomingRequests', filter=filter('resource_type', 'Microsoft.ServiceBus/namespaces'), extrapolation='zero').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
