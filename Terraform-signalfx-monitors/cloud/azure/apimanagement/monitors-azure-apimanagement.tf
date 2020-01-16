resource "signalfx_detector" "apimgt_status" {
	name = "API Management is down"

	/*query = <<EOQ max last_5m
		:avg:azure.apimanagement_service.status${module.filter-tags.query_alert} by {resource_group,region,name} < 1
	EOQ*/

	program_text = <<-EOF
		signal = data('XXXXX', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "apimgt_failed_requests" {
	name = "API Management too many failed requests"

	program_text = <<-EOF
		A = data('FailedRequests', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name'], rollup='rate', extrapolation='zero')
		B = data('TotalRequests', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name'], rollup='rate', extrapolation='zero')
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "apimgt_other_requests" {
	name = "API Management too many other requests"

	program_text = <<-EOF
		A = data('FailedRequests', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name'], rollup='rate', extrapolation='zero')
		B = data('TotalRequests', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name'], rollup='rate', extrapolation='zero')
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "apimgt_unauthorized_requests" {
	name = "API Management too many unauthorized requests"

	program_text = <<-EOF
		A = data('UnauthorizedRequests', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name'], rollup='rate', extrapolation='zero')
		B = data('TotalRequests', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name'], rollup='rate', extrapolation='zero')
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "apimgt_successful_requests" {
	name = "API Management successful requests rate too low"

	program_text = <<-EOF
		A = data('SuccessfulRequests', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name'], rollup='rate', extrapolation='zero')
		B = data('TotalRequests', filter=filter('resource_type', 'Microsoft.ApiManagement/service')).mean(by=['resource_group_id', 'region', 'name'], rollup='rate', extrapolation='zero')
		signal = ((A/B)*100).max(over='5m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Max < 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
