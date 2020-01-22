#
# 4XX Errors
#
resource "signalfx_detector" "error_rate_4xx" {
	name = "GCP LB 4xx errors"

	program_text = <<-EOF
		A = data('https/request_count', filter=filter('service', 'loadbalancing') and filter('response_code_class', '400'), extrapolation='zero', rollup='rate').sum()
		B = data('https/request_count', filter=filter('service', 'loadbalancing'), extrapolation='zero', rollup='rate').sum()
		signal = ((A/(B+5))*100).min(over='5m')
		detect(when(signal > 60)).publish('CRIT')
	EOF

	rule {
		description = "Min > 60 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# 5XX Errors
#
resource "signalfx_detector" "error_rate_5xx" {
	name = "GCP LB 5xx errors"

	program_text = <<-EOF
		A = data('https/request_count', filter=filter('service', 'loadbalancing') and filter('response_code_class', '500'), extrapolation='zero', rollup='rate').sum()
		B = data('https/request_count', filter=filter('service', 'loadbalancing'), extrapolation='zero', rollup='rate').sum()
		signal = ((A/(B+5))*100).min(over='5m')
		detect(when(signal > 40)).publish('CRIT')
	EOF

	rule {
		description = "Min > 40 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Backend Latency for service
#
resource "signalfx_detector" "backend_latency_service" {
	name = "GCP LB service backend latency"

	program_text = <<-EOF
		signal = data('https/backend_latencies', filter=filter('service', 'loadbalancing') and filter('backend_target_type', 'BACKEND_SERVICE'), extrapolation='zero').min(by=['backend_target_name']).min(over='10m')
		detect(when(signal > 1500)).publish('CRIT')
	EOF

	rule {
		description = "Min > 1500 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Backend Latency for bucket
#
resource "signalfx_detector" "backend_latency_bucket" {
	name = "GCP LB bucket backend latency"

	program_text = <<-EOF
		signal = data('https/backend_latencies', filter=filter('service', 'loadbalancing') and filter('backend_target_type', 'BACKEND_BUCKET'), extrapolation='zero').min(by=['backend_target_name']).min(over='10m')
		detect(when(signal > 8000)).publish('CRIT')
	EOF

	rule {
		description = "Min > 8000 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Request Count
#
resource "signalfx_detector" "request_count" {
	name = "GCP LB Requests count increased abruptly"

	program_text = <<-EOF
		signal = data('https/request_count', filter=filter('service', 'loadbalancing'), extrapolation='zero', rollup='sum').sum(over='5m')
		detect(when(signal > 500)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 500 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
