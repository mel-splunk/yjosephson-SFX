# Monitoring App Gateway status
resource "signalfx_detector" "appgateway_status" {
	name = "App Gateway is down"

	program_text = <<-EOF
		signal = data('ResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal != 1)).publish('CRIT')
	EOF

	rule {
		description = "Max != 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Gateway current_connections
resource "signalfx_detector" "current_connection" {
	name = "App Gateway has no connection"

	program_text = <<-EOF
		signal = data('CurrentConnections', filter=filter('resource_type', 'Microsoft.Network/applicationGateways')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Gateway backend_connect_time
resource "signalfx_detector" "appgateway_backend_connect_time" {
	name = "App Gateway backend connect time is too high"

	program_text = <<-EOF
		signal = data('BackendConnectTime', filter=filter('resource_type', 'Microsoft.Network/applicationGateways')).sum(by=['resource_group_id', 'region', 'name', 'BackendHttpSetting', 'BackendPool', 'BackendServer']).max(over='5m')
		detect(when(signal > 50)).publish('CRIT')
	EOF

	rule {
		description = "Max > 50 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Gateway failed_requests
resource "signalfx_detector" "appgateway_failed_requests" {
	name = "App Gateway failed requests"

	program_text = <<-EOF
		A = data('FailedRequests', filter=filter('resource_type', 'Microsoft.Network/applicationGateways'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name', 'BackendSettingsPool'])
		B = data('TotalRequests', filter=filter('resource_type', 'Microsoft.Network/applicationGateways'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name', 'BackendSettingsPool'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Min > 95 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Gateway unhealthy_host_ratio
resource "signalfx_detector" "appgateway_healthy_host_ratio" {
	name = "App Gateway backend unhealthy host ratio is too high"

	program_text = <<-EOF
		A = data('UnhealthyHostCount', filter=filter('resource_type', 'Microsoft.Network/applicationGateways'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name', 'BackendSettingsPool'])
		B = data('HealthyHostCount', filter=filter('resource_type', 'Microsoft.Network/applicationGateways'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name', 'BackendSettingsPool'])
		signal = ((A/(A+B))*100).max(over='5m')
		detect(when(signal > 75)).publish('CRIT')
	EOF

	rule {
		description = "Max > 75 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Gateway response_status 4xx
resource "signalfx_detector" "appgateway_http_4xx_errors" {
	name = "App Gateway HTTP 4xx errors rate is too high"

	program_text = <<-EOF
		A = data('ResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways') and filter('httpstatusgroup', '4xx'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name'])
		B = data('ResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name'])
		signal = ((A/B)*100).max(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Max > 95 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Gateway response_status 5xx
resource "signalfx_detector" "appgateway_http_5xx_errors" {
	name = "App Gateway HTTP 5xx errors rate is too high"

	program_text = <<-EOF
		A = data('ResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways') and filter('httpstatusgroup', '5xx'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name'])
		B = data('ResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name'])
		signal = ((A/B)*100).max(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Max > 95 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Gateway Backend response_status 4xx
resource "signalfx_detector" "appgateway_backend_http_4xx_errors" {
	name = "App Gateway backend HTTP 4xx errors rate is too high"

	program_text = <<-EOF
		A = data('BackendResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways') and filter('httpstatusgroup', '4xx'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name', 'BackendHttpSetting', 'BackendPool', 'BackendServer'])
		B = data('BackendResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name', 'BackendHttpSetting', 'BackendPool', 'BackendServer'])
		signal = ((A/B)*100).max(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Max > 95 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring App Gateway Backend response_status 5xx
resource "signalfx_detector" "appgateway_backend_http_5xx_errors" {
	name = "App Gateway backend HTTP 5xx errors rate is too high"

	program_text = <<-EOF
		A = data('BackendResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways') and filter('httpstatusgroup', '5xx'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name', 'BackendHttpSetting', 'BackendPool', 'BackendServer'])
		B = data('BackendResponseStatus', filter=filter('resource_type', 'Microsoft.Network/applicationGateways'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'region', 'name', 'BackendHttpSetting', 'BackendPool', 'BackendServer'])
		signal = ((A/B)*100).max(over='5m')
		detect(when(signal > 95)).publish('CRIT')
	EOF

	rule {
		description = "Max > 95 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
