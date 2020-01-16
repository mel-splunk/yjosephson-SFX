# Errors Percent
resource "signalfx_detector" "pct_errors" {
	name = "Lambda Percentage of errors"

	program_text = <<-EOF
		A = data('Errors', filter=filter('namespace', 'AWS/Lambda'), rollup='sum', extrapolation='zero').sum(by=['aws_region', 'FunctionName'])
		B = data('Invocations', filter=filter('namespace', 'AWS/Lambda'), rollup='sum').sum(by=['aws_region', 'FunctionName'])
		signal = (A / B).scale(100).sum(over='1h')
		detect(when(signal > 30)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 30 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

# Errors Absolute Value
resource "signalfx_detector" "errors" {
	name = "Lambda Number of errors"

	program_text = <<-EOF
		signal = data('Errors', filter=filter('namespace', 'AWS/Lambda'), rollup='sum', extrapolation='zero').sum(by=['aws_region', 'FunctionName']).sum(over='1h')
		detect(when(signal > 3)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 3 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

# Throttles
resource "signalfx_detector" "throttles" {
	name = "Lambda Invocations throttled due to concurrent limit reached"

	program_text = <<-EOF
		signal = data('Throttles', filter=filter('namespace', 'AWS/Lambda'), rollup='sum', extrapolation='zero').sum(by=['aws_region', 'FunctionName']).sum(over='1h')
		detect(when(signal > 3)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 3 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

# INVOCATIONS
resource "signalfx_detector" "invocations" {
	name = "Lambda Number of invocations"

	program_text = <<-EOF
		signal = data('invocations', filter=filter('namespace', 'AWS/Lambda'), rollup='sum', extrapolation='zero').sum(by=['aws_region', 'FunctionName']).sum(over='30m')
		detect(when(signal <= 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum <= 1 for last 30m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
