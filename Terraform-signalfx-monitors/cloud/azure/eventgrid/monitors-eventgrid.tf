resource "signalfx_detector" "eventgrid_no_successful_message" {
	name = "Event Grid no successful message"

	program_text = <<-EOF
		signal = data('PublishSuccessCount', filter=filter('resource_type', 'Microsoft.EventGrid/topics')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal < 0)).publish('CRIT')
	EOF

	rule {
		description = "Min < 0 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "eventgrid_failed_messages" {
	name = "Event Grid too many failed messages"

	program_text = <<-EOF
		A = data('PublishFailCount', filter=filter('resource_type', 'Microsoft.EventGrid/topics'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('PublishSuccessCount', filter=filter('resource_type', 'Microsoft.EventGrid/topics'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		C = data('UnmatchedEventCount', filter=filter('resource_type', 'Microsoft.EventGrid/topics'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B+C))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "eventgrid_unmatched_events" {
	name = "Event Grid too many unmatched events"

	program_text = <<-EOF
		A = data('UnmatchedEventCount', filter=filter('resource_type', 'Microsoft.EventGrid/topics'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('PublishSuccessCount', filter=filter('resource_type', 'Microsoft.EventGrid/topics'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		C = data('PublishFailCount', filter=filter('resource_type', 'Microsoft.EventGrid/topics'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/(A+B+C))*100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
