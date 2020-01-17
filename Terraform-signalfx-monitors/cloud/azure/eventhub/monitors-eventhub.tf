resource "signalfx_detector" "eventhub_status" {
	name = "Event Hub is down"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.EventHub/namespaces')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal != 1)).publish('CRIT')
	EOF

	rule {
		description = "Max != 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "eventhub_failed_requests" {
	name = "Event Hub too many failed requests"

	/*query = <<EOQ
		${var.failed_requests_rate_time_aggregator}(${var.failed_requests_rate_timeframe}): (
			default(avg:azure.eventhub_namespaces.failed_requests${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate(), 0) /
			default(avg:azure.eventhub_namespaces.incoming_requests${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate(), 1)
		) * 100 > ${var.failed_requests_rate_thresold_critical}
EOQ*/

	program_text = <<-EOF
		A = data('FailedRequests', filter=filter('resource_type', 'Microsoft.EventHub/namespaces'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('IncomingRequests', filter=filter('resource_type', 'Microsoft.EventHub/namespaces'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "eventhub_errors" {
	name = "Event Hub too many errors"

	/*query = <<EOQ
		${var.errors_rate_time_aggregator}(${var.errors_rate_timeframe}): ( (
			default(avg:azure.eventhub_namespaces.internal_server_errors${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate(), 0) +
			default(avg:azure.eventhub_namespaces.server_busy_errors${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate(), 0) +
			default(avg:azure.eventhub_namespaces.other_errors${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate(), 0) ) /
			default(avg:azure.eventhub_namespaces.incoming_requests${module.filter-tags.query_alert} by {resource_group,region,name}.as_rate(), 1)
		) * 100 > ${var.errors_rate_thresold_critical}
EOQ*/

	program_text = <<-EOF
		A = data('ServerErrors', filter=filter('resource_type', 'Microsoft.EventHub/namespaces'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('UserErrors', filter=filter('resource_type', 'Microsoft.EventHub/namespaces'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		C = data('QuotaExceededErrors', filter=filter('resource_type', 'Microsoft.EventHub/namespaces'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		D = data('IncomingRequests', filter=filter('resource_type', 'Microsoft.EventHub/namespaces'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = (((+B+C)/D)*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
