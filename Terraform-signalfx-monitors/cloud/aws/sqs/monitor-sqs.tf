# Approximate Number of Visible Messages
resource "signalfx_monitor" "visible_messages" {
	name = "SQS Visible messages"

	program_text = <<-EOF
		signal = data('ApproximateNumberOfMessagesVisible', filter=filter('namespace', 'AWS/SQS')).mean(by=['aws_region','QueueName']).min(over='30m')
		detect(when(signal > 2)).publish('CRIT')
	EOF

	rule {
		description = "Min > 2 for last 30m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

# Age of the Oldest Message
resource "signalfx_monitor" "age_of_oldest_message" {
	name = "SQS Age of the oldest message"

	program_text = <<-EOF
		signal = data('ApproximateAgeOfOldestMessage', filter=filter('namespace', 'AWS/SQS')).mean(by=['aws_region','QueueName']).min(over='30m')
		detect(when(signal > 600)).publish('CRIT')
	EOF

	rule {
		description = "Min > 600 for last 30m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
