# Approximate Number of Visible Messages
resource "signalfx_monitor" "visible_messages" {
  count   = var.visible_messages_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] SQS Visible messages {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
    ${var.visible_messages_time_aggregator}(${var.visible_messages_timeframe}):
        avg:aws.sqs.approximate_number_of_messages_visible${module.filter-tags.query_alert} by {region,queuename}
    > ${var.visible_messages_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('ApproximateNumberOfMessagesVisible', filter=filter('namespace', 'AWS/SQS'), rollup='mean').${var.visible_messages_time_aggregator}.mean(by=['aws_region','QueueName'])
			
			detect(when(signal > ${var.visible_messages_threshold_critical}, ${var.visible_messages_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.visible_messages_message, var.message)
		severity = "Critical"
	}

}

# Age of the Oldest Message
resource "signalfx_monitor" "age_of_oldest_message" {
  count   = var.age_of_oldest_message_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] SQS Age of the oldest message {{#is_alert}}{{{comparator}}} {{threshold}}s ({{value}}s){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}s ({{value}}s){{/is_warning}}"

  /*query = <<EOQ
    ${var.age_of_oldest_message_time_aggregator}(${var.age_of_oldest_message_timeframe}):
      avg:aws.sqs.approximate_age_of_oldest_message${module.filter-tags.query_alert} by {region,queuename}
    > ${var.age_of_oldest_message_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('ApproximateAgeOfOldestMessage', filter=filter('namespace', 'AWS/SQS'), rollup='mean').${var.age_of_oldest_message_time_aggregator}.mean(by=['aws_region','QueueName'])
			
			detect(when(signal > ${var.age_of_oldest_message_threshold_critical}, ${var.age_of_oldest_message_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.age_of_oldest_message_message, var.message)
		severity = "Critical"
	}

}
