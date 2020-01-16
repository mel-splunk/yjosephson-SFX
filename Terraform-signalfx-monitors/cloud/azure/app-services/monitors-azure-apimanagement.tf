# Monitoring App Services response time
resource "signalfx_detector" "appservices_response_time" {
	name = "App Services response time too high"

	program_text = <<-EOF
		signal = data('AverageResponseTime', filter=filter('resource_type', 'Microsoft.Web/sites')).mean(by=['resource_group_id', 'azure_region', 'azure_resource_name', 'Instance']).min(over='5m')
		detect(when(signal > 10)).publish('CRIT')
	EOF

	rule {
		description = "Min > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
	
}

# Monitoring App Services memory usage
resource "signalfx_detector" "appservices_memory_usage_count" {
	name = "App Services memory usage"

	program_text = <<-EOF
		signal = data('MemoryWorkingSet', filter=filter('resource_type', 'Microsoft.Web/sites')).mean(by=['resource_group_id', 'azure_region', 'azure_resource_name', 'Instance']).min(over='5m')
		detect(when(signal > 1073741824)).publish('CRIT') # 1Gb
	EOF

	rule {
		description = "Min > 1Gb for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

# Monitoring App Services 5xx errors percent
resource "signalfx_detector" "appservices_http_5xx_errors_count" {
	name = "App Services HTTP 5xx errors too high"

	program_text = <<-EOF
		A = data('Http5xx', filter=filter('resource_type', 'Microsoft.Web/sites'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id','azure_region','azure_resource_name','Instance'])
		B = data('Requests', filter=filter('resource_type', 'Microsoft.Web/sites'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id','azure_region','azure_resource_name','Instance'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

# Monitoring App Services 4xx errors percent
resource "signalfx_detector" "appservices_http_4xx_errors_count" {
	name = "App Services HTTP 4xx errors too high"

	program_text = <<-EOF
		A = data('Http4xx', filter=filter('resource_type', 'Microsoft.Web/sites'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id','azure_region','azure_resource_name','Instance'])
		B = data('Requests', filter=filter('resource_type', 'Microsoft.Web/sites'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id','azure_region','azure_resource_name','Instance'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Services HTTP 2xx & 3xx status pages percent
resource "signalfx_detector" "appservices_http_success_status_rate" {
	name = "App Services HTTP successful responses too low"

	program_text = <<-EOF
		A = data('Http2xx', filter=filter('resource_type', 'Microsoft.Web/sites'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id','azure_region','azure_resource_name','Instance'])
		B = data('Http3xx', filter=filter('resource_type', 'Microsoft.Web/sites'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id','azure_region','azure_resource_name','Instance'])
		C = data('Requests', filter=filter('resource_type', 'Microsoft.Web/sites'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id','azure_region','azure_resource_name','Instance'])
		signal = (((A+B)/C)*100).max(over='5m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Max < 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Services status
resource "signalfx_detector" "appservices_status" {
	name = "App Services is down"

	program_text = <<-EOF
		signal = data('HealthCheckStatus', filter=filter('resource_type', 'Microsoft.Web/sites'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id','azure_region','azure_resource_name','Instance']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
