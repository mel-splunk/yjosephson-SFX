resource "signalfx_detector" "function_http_5xx_errors_rate" {
	name = "Function App HTTP 5xx errors too high"

	program_text = <<-EOF
		A = data('Http5xx', filter=filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'true'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('FunctionExecutionCount', filter=filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'true'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/B)*100).min(over='5m')
		detect(when(signal > 20)).publish('CRIT')
	EOF

	rule {
		description = "Min > 20 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "function_high_connections_count" {
	name = "Function App connections count too high"

	/*query = <<EOQ
		${var.high_connections_count_time_aggregator}(${var.high_connections_count_timeframe}):
			default(azure.functions.connections${module.filter-tags.query_alert} by {resource_group,region,name,instance}.as_rate(), 0)
		> ${var.high_connections_count_threshold_critical}
EOQ*/

	program_text = <<-EOF
		signal = data('XXXX', filter=filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'true'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal > 590)).publish('CRIT')
	EOF

	rule {
		description = "Min > 590 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "function_high_threads_count" {
	name = "Function App threads count too high"

	/*query = <<EOQ
		${var.high_threads_count_time_aggregator}(${var.high_threads_count_timeframe}):
			default(azure.functions.thread_count${module.filter-tags.query_alert} by {resource_group,region,name,instance}.as_rate(), 0)
		> ${var.high_threads_count_threshold_critical}
EOQ*/

	program_text = <<-EOF
		signal = data('XXXX', filter=filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'true'), extrapolation='zero', rollup='rate').mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal > 510)).publish('CRIT')
	EOF

	rule {
		description = "Min > 510 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
