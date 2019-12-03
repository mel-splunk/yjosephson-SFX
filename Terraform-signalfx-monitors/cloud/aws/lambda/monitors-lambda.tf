# Errors Percent
resource "signalfx_detector" "pct_errors" {
  count   = var.pct_errors_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Lambda Percentage of errors {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

/*  query = <<EOQ
    ${var.pct_errors_time_aggregator}(${var.pct_errors_timeframe}):
      default(
        (default(sum:aws.lambda.errors${module.filter-tags.query_alert} by {region,functionname}.as_count(),0)
        /
        default(sum:aws.lambda.invocations${module.filter-tags.query_alert} by {region,functionname}.as_count(),1))
        * 100,0)
      > ${var.pct_errors_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('aws.lambda.errors', rollup='sum').${var.pct_errors_time_aggregator}.sum(by=['aws_region','aws_function_name']).count(by=['aws_region'])
			B = data('aws.lambda.invocation', rollup='sum').${var.pct_errors_time_aggregator}.sum(by=['aws_region','aws_function_name']).count(by=['aws_region'])
		  signal = (A / B) * 100
			detect(when(signal > ${var.pct_errors_threshold_critical}, max('${var.pct_errors_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.pct_errors_message, var.message)
		severity = "Critical"
	}

}

# Errors Absolute Value
resource "signalfx_detector" "errors" {
  count   = var.errors_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Lambda Number of errors {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

 /* query = <<EOQ
    ${var.errors_time_aggregator}(${var.errors_timeframe}):
      default(sum:aws.lambda.errors${module.filter-tags.query_alert} by {region,functionname}.as_count(),0)
      > ${var.errors_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('aws.lambda.errors', rollup='sum').${var.errors_time_aggregator}.sum(by=['aws_region','aws_function_name']).count(by=['aws_region'])
			
			detect(when(signal > ${var.errors_threshold_critical}, max('${var.errors_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.errors_message, var.message)
		severity = "Critical"
	}

}

# Throttles
resource "signalfx_detector" "throttles" {
  count   = var.throttles_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Lambda Invocations throttled due to concurrent limit reached {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
    ${var.throttles_time_aggregator}(${var.throttles_timeframe}):
      default(sum:aws.lambda.throttles${module.filter-tags.query_alert} by {region,functionname}.as_count(),0)
      > ${var.throttles_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('aws.lambda.throttles', rollup='sum').${var.throttles_time_aggregator}.sum(by=['aws_region','aws_function_name']).count(by=['aws_region'])
			
			detect(when(signal > ${var.throttles_critical}, max('${var.throttles_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.throttles_message, var.message)
		severity = "Critical"
	}

}

# INVOCATIONS
resource "signalfx_detector" "invocations" {
  count   = var.invocations_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Lambda Number of invocations {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
    ${var.invocations_time_aggregator}(${var.invocations_timeframe}):
      default(sum:aws.lambda.invocations${module.filter-tags.query_alert} by {region,functionname}.as_count(),0)
      <= ${var.invocations_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('aws.lambda.invocations', rollup='sum').${var.invocations_time_aggregator}.sum(by=['aws_region','aws_function_name']).count(by=['aws_region'])
			
			detect(when(signal <= ${var.invocations_critical}, max('${var.invocations_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.invocations_message, var.message)
		severity = "Critical"
	}

}
