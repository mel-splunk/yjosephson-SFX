######################
# All Subscriptions #
######################

#
# oldest_unacked_message_age
#
resource "signalfx_detector" "oldest_unacked_message_age" {
	name = "Pub/Sub Subscription oldest unacknowledged message"

	program_text = <<-EOF
		signal = data('subscription/oldest_unacked_message_age', filter=filter('monitored_resource', 'pubsub_subscription')).mean(by=['subscription_id']).min(over='5m')
		detect(when(signal >= 120)).publish('CRIT')
	EOF

	rule {
		description = "Min >= 120 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

######################
# Push Subscriptions #
######################

#
# subscription_push_latency
#
resource "signalfx_detector" "subscription_push_latency" {
	name = "Pub/Sub Subscription latency on push endpoint"

	program_text = <<-EOF
		signal = data('subscription/push_request_count', filter=filter('monitored_resource', 'pubsub_subscription')).mean(by=['subscription_id']).mean(over='10m')
		detect(when(signal >= 5000)).publish('CRIT')
	EOF

	rule {
		description = "Average >= 5000 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# subscription_push_latency_anomaly
#
resource "signalfx_detector" "subscription_push_latency_anomaly" {
	name = "Pub/Sub Subscription latency on push endpoint changed abnormally"

	/*query = <<EOQ
	avg (last_10m):
		anomalies(
				avg:gcp.pubsub.subscription.push_request_latencies.avg{${var.filter_tags}} by {subscription_id}
				'${var.subscription_push_latency_anomaly_detection_algorithm}',
				avg: gcp.pubsub.subscription.push_request_latencies.sumsqdev{${var.filter_tags}} by {subscription_id},
				direction='${var.subscription_push_latency_anomaly_direction}',
				alert_window='${var.subscription_push_latency_anomaly_alert_window}',
				interval=${var.subscription_push_latency_anomaly_interval},
				count_default_zero='${var.subscription_push_latency_anomaly_count_default_zero}'
				${var.subscription_push_latency_anomaly_seasonality == "agile" ? format(",seasonality='%s'", var.subscription_push_latency_anomaly_seasonality) : ""}
			)	>= 2
	EOQ*/

	/*program_text = <<-EOF
		# Using anomalies will need to be configure in UI 
		from signalfx.detectors.against_periods import against_periods
			
		signal = data('subscription/push_request_latencies', rollup='mean').${var.subscription_push_latency_anomaly_time_aggregator}.mean(by=['subscription_id'])
		against_periods.detector_mean_std(stream=A, window_to_compare='30m', space_between_windows='1w', num_windows=4, fire_num_stddev=3, clear_num_stddev=2.5, discard_historical_outliers=True, orientation='above').publish('CRIT')
		detect(when(signal >= 2)).publish('CRIT')
	EOF

	rule {
		description = "Average >= 5000 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/

}
