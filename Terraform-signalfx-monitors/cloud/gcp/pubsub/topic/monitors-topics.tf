#
# Sending Operations Count
#
resource "signalfx_detector" "sending_operations_count" {
	name = "Pub/Sub Topic sending messages operations"

	program_text = <<-EOF
		signal = data('topic/send_message_operation_count', filter=filter('monitored_resource', 'pubsub_topic'), rollup='sum').mean(by=['topic_id']).sum(over='30m')
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	rule {
		description = "Sum <= 0 for last 30m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Unavailable Sending Operations Count
#
resource "signalfx_detector" "unavailable_sending_operations_count" {
	name = "Pub/Sub Topic sending messages with result unavailable"

	program_text = <<-EOF
		signal = data('topic/send_message_operation_count', filter=filter('monitored_resource', 'pubsub_topic') and filter('response_code', 'unavailable'), rollup='sum').mean(by=['topic_id']).sum(over='10m')
		detect(when(signal >= 4)).publish('CRIT')
	EOF

	rule {
		description = "Sum >= 4 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Unavailable Sending Operations Ratio
#
resource "signalfx_detector" "unavailable_sending_operations_ratio" {
	name = "Pub/Sub Topic ratio of sending messages with result unavailable"

	program_text = <<-EOF
		A = data('topic/send_message_operation_count', filter=filter('monitored_resource', 'pubsub_topic') and filter('response_code', 'unavailable'), rollup='rate').mean(by=['topic_id'])
		B = data('topic/send_message_operation_count', filter=filter('monitored_resource', 'pubsub_topic'), rollup='rate').mean(by=['topic_id'])
		signal = ((100*A)/B).sum(over='10m')
		detect(when(signal >= 20)).publish('CRIT')
	EOF

	rule {
		description = "Sum >= 20 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
