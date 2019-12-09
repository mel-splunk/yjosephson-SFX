######################
# All Subscriptions #
######################

#
# oldest_unacked_message_age
#
resource "signalfx_monitor" "oldest_unacked_message_age" {
  count   = var.oldest_unacked_message_age_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Pub/Sub Subscription oldest unacknowledged message {{#is_alert}}{{{comparator}}} {{threshold}}s ({{value}}s){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}s ({{value}}s){{/is_warning}}"

  /*query = <<EOQ
  ${var.oldest_unacked_message_age_time_aggregator}(${var.oldest_unacked_message_age_timeframe}):
    avg:gcp.pubsub.subscription.oldest_unacked_message_age{${var.filter_tags}} by {subscription_id}
    >= ${var.oldest_unacked_message_age_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('subscription/oldest_unacked_message_age', rollup='mean').${var.oldest_unacked_message_age_time_aggregator}.mean(by=['subscription_id'])
			
			detect(when(signal >= ${var.oldest_unacked_message_age_threshold_critical}, ${var.oldest_unacked_message_age_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.oldest_unacked_message_age_message, var.message)
		severity = "Critical"
	}

}

######################
# Push Subscriptions #
######################

#
# subscription_push_latency
#
resource "signalfx_monitor" "subscription_push_latency" {
  count   = var.subscription_push_latency_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Pub/Sub Subscription latency on push endpoint {{#is_alert}}{{{comparator}}} {{threshold}}s ({{value}}s){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}s ({{value}}s){{/is_warning}}"

  /*query = <<EOQ
  ${var.subscription_push_latency_time_aggregator}(${var.subscription_push_latency_timeframe}):
    avg:gcp.pubsub.subscription.push_request_latencies.avg{${var.filter_tags}} by {subscription_id}
    >= ${var.subscription_push_latency_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('subscription/push_request_latencies', rollup='mean').${var.subscription_push_latency_time_aggregator}.mean(by=['subscription_id'])
			
			detect(when(signal >= ${var.subscription_push_latency_threshold_critical}, ${var.subscription_push_latency_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.subscription_push_latency_message, var.message)
		severity = "Critical"
	}

}

#
# subscription_push_latency_anomaly
#
resource "signalfx_monitor" "subscription_push_latency_anomaly" {
  count   = var.subscription_push_latency_anomaly_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Pub/Sub Subscription latency on push endpoint changed abnormally {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
  ${var.subscription_push_latency_anomaly_time_aggregator}(${var.subscription_push_latency_anomaly_timeframe}):
    anomalies(
        avg:gcp.pubsub.subscription.push_request_latencies.avg{${var.filter_tags}} by {subscription_id}
        '${var.subscription_push_latency_anomaly_detection_algorithm}',
        avg: gcp.pubsub.subscription.push_request_latencies.sumsqdev{${var.filter_tags}} by {subscription_id},
        direction='${var.subscription_push_latency_anomaly_direction}',
        alert_window='${var.subscription_push_latency_anomaly_alert_window}',
        interval=${var.subscription_push_latency_anomaly_interval},
        count_default_zero='${var.subscription_push_latency_anomaly_count_default_zero}'
        ${var.subscription_push_latency_anomaly_seasonality == "agile" ? format(",seasonality='%s'", var.subscription_push_latency_anomaly_seasonality) : ""}
      )

    >= ${var.subscription_push_latency_anomaly_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      /* Using anomalies will need to be configure in UI */
      from signalfx.detectors.against_periods import against_periods
		  
      signal = data('subscription/push_request_latencies', rollup='mean').${var.subscription_push_latency_anomaly_time_aggregator}.mean(by=['subscription_id'])
			against_periods.detector_mean_std(stream=A, window_to_compare='30m', space_between_windows='1w', num_windows=4, fire_num_stddev=3, clear_num_stddev=2.5, discard_historical_outliers=True, orientation='above').publish('CRIT')

			detect(when(signal >= ${var.subscription_push_latency_anomaly_threshold_critical}, ${var.subscription_push_latency_anomaly_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.subscription_push_latency_anomaly_message, var.message)
		severity = "Critical"
	}

}
