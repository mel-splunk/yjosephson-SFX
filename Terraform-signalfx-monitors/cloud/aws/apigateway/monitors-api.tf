# Monitoring Api Gateway latency
resource "signalfx_detector" "API_Gateway_latency" {
	name = "API Gateway latency"

	program_text = <<-EOF
		signal = data('Latency', filter=filter('namespace', 'AWS/ApiGateway'), extrapolation='zero').mean(by=['aws_region','ApiName', 'Stage']).min(over='5m')
		detect(when(signal > 3000)).publish('CRIT')
	EOF

	rule {
		description = "Min > 3000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

# Monitoring API Gateway 5xx errors percent
resource "signalfx_detector" "API_http_5xx_errors_count" {
	name = "API Gateway HTTP 5xx errors"

	program_text = <<-EOF
		A = data('5XXError', filter=filter('namespace', 'AWS/ApiGateway'), extrapolation='zero', rollup='rate').mean(by=['aws_region','ApiName','Stage'])
		B = data('Count', filter=filter('namespace', 'AWS/ApiGateway'), extrapolation='zero', rollup='rate').mean(by=['aws_region','ApiName','Stage'])
		signal = (A/(B+5)).scale(100).min(over='5m')
		detect(when(signal > 20)).publish('CRIT')
	EOF

	rule {
		description = "Min > 20 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

# Monitoring API Gateway 4xx errors percent
resource "signalfx_detector" "API_http_4xx_errors_count" {
	name = "API Gateway HTTP 4xx errors"

	program_text = <<-EOF
		A = data('4XXError', filter=filter('namespace', 'AWS/ApiGateway'), extrapolation='zero', rollup='rate').mean(by=['aws_region','ApiName','Stage'])
		B = data('Count', filter=filter('namespace', 'AWS/ApiGateway'), extrapolation='zero', rollup='rate').mean(by=['aws_region','ApiName','Stage'])
		signal = (A/(B+5)).scale(100).min(over='5m')
		detect(when(signal > 30)).publish('CRIT')
	EOF

	rule {
		description = "Min > 30 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
