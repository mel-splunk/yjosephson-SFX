#
# Sending Operations Count
#
resource "signalfx_monitor" "sending_operations_count" {
  count   = var.sending_operations_count_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Pub/Sub Topic sending messages operations {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
  ${var.sending_operations_count_time_aggregator}(${var.sending_operations_count_timeframe}):
    default(avg:gcp.pubsub.topic.send_message_operation_count{${var.filter_tags}} by {topic_id}.as_count(), 0)
    <= ${var.sending_operations_count_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('topic/send_message_operation_count', rollup='mean').${var.sending_operations_count_time_aggregator}.mean(by=['topic_id']).count(by=['topic_id'])

			detect(when(signal <= ${var.sending_operations_count_threshold_critical}, '${var.sending_operations_count_timeframe}')).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.sending_operations_count_message, var.message)
		severity = "Critical"
	}

}

#
# Unavailable Sending Operations Count
#
resource "signalfx_monitor" "unavailable_sending_operations_count" {
  count   = var.unavailable_sending_operations_count_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Pub/Sub Topic sending messages with result unavailable {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
  ${var.unavailable_sending_operations_count_time_aggregator}(${var.unavailable_sending_operations_count_timeframe}):
    default(avg:gcp.pubsub.topic.send_message_operation_count{${var.filter_tags},response_code:unavailable} by {topic_id}.as_count(), 0)
    >= ${var.unavailable_sending_operations_count_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('topic/send_message_operation_count', rollup='mean', filter=filter('response_code', 'unavailable')).${var.unavailable_sending_operations_count_time_aggregator}.mean(by=['topic_id']).count(by=['topic_id'])

			detect(when(signal >= ${var.unavailable_sending_operations_count_threshold_critical}, '${var.unavailable_sending_operations_count_timeframe}')).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.unavailable_sending_operations_count_message, var.message)
		severity = "Critical"
	}

}

#
# Unavailable Sending Operations Ratio
#
resource "signalfx_monitor" "unavailable_sending_operations_ratio" {
  count   = var.unavailable_sending_operations_ratio_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Pub/Sub Topic ratio of sending messages with result unavailable {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
  ${var.unavailable_sending_operations_ratio_time_aggregator}(${var.unavailable_sending_operations_ratio_timeframe}):
   (100 * default(sum:gcp.pubsub.topic.send_message_operation_count{${var.filter_tags},response_code:unavailable} by {topic_id}.as_rate(), 0))
    /
    default(sum:gcp.pubsub.topic.send_message_operation_count{${var.filter_tags}} by {topic_id}.as_rate(), 0)
    >= ${var.unavailable_sending_operations_ratio_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('topic/send_message_operation_count', rollup='sum', filter=filter('response_code', 'unavailable')).${var.unavailable_sending_operations_ratio_time_aggregator}.sum(by=['topic_id']).scale(100)
      B = data('topic/send_message_operation_count', rollup='sum').${var.unavailable_sending_operations_ratio_time_aggregator}.sum(by=['topic_id'])

      signal = (A/B)
			detect(when(signal >= ${var.unavailable_sending_operations_ratio_threshold_critical}, '${var.unavailable_sending_operations_ratio_timeframe}')).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.unavailable_sending_operations_ratio_message, var.message)
		severity = "Critical"
	}

}
