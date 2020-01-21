resource "signalfx_detector" "status" {
	name = "Stream Analytics is down"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.StreamAnalytics/streamingjobs')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "su_utilization" {
	name = "Stream Analytics streaming units utilization too high"

	program_text = <<-EOF
		signal = data('ResourceUtilization', filter=filter('resource_type', 'Microsoft.StreamAnalytics/streamingjobs')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).min(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "failed_function_requests" {
	name = "Stream Analytics too many failed requests"

	program_text = <<-EOF
		A = data('AMLCalloutFailedRequests', filter=filter('resource_type', 'Microsoft.StreamAnalytics/streamingjobs'), extrapolation='zero', rollup='rate').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		B = data('AMLCalloutRequests', filter=filter('resource_type', 'Microsoft.StreamAnalytics/streamingjobs'), extrapolation='zero', rollup='rate').mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Min > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "conversion_errors" {
	name = "Stream Analytics too many conversion errors"

	program_text = <<-EOF
		signal = data('ConversionErrors', filter=filter('resource_type', 'Microsoft.StreamAnalytics/streamingjobs')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).min(over='5m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Min > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "runtime_errors" {
	name = "Stream Analytics too many runtime errors"

	program_text = <<-EOF
		signal = data('Errors', filter=filter('resource_type', 'Microsoft.StreamAnalytics/streamingjobs')).mean(by=['azure_resource_group_name', 'azure_region', 'azure_resource_name']).min(over='5m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Min > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
