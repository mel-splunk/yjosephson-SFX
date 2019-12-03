# Monitoring Api Gateway latency
resource "signalfx_monitor" "API_Gateway_latency" {
  count   = var.latency_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] API Gateway latency {{#is_alert}}{{{comparator}}} {{threshold}}ms ({{value}}ms){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}ms ({{value}}ms){{/is_warning}}"
  message = coalesce(var.latency_message, var.message)
  type    = "query alert"

  /*query = <<EOQ
    ${var.latency_time_aggregator}(${var.latency_timeframe}):
      default(avg:aws.apigateway.latency{${var.filter_tags}} by {region,apiname,stage}, 0)
    > ${var.latency_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('Latency', rollup='mean').${var.latency_time_aggregator}.mean(by=['aws_region','namespace'])
			
      detect(when(signal > ${var.latency_threshold_critical}, max('${var.latency_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.latency_message, var.message)
		severity = "Critical"
	}

}

# Monitoring API Gateway 5xx errors percent
resource "signalfx_monitor" "API_http_5xx_errors_count" {
  count   = var.http_5xx_requests_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] API Gateway HTTP 5xx errors {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.http_5xx_requests_time_aggregator}(${var.http_5xx_requests_timeframe}):
      default(avg:aws.apigateway.5xxerror{${var.filter_tags}} by {region,apiname,stage}.as_rate(), 0) / (
      default(avg:aws.apigateway.count{${var.filter_tags}} by {region,apiname,stage}.as_rate() + ${var.artificial_requests_count}, 1))
      * 100 > ${var.http_5xx_requests_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('5XXError', rollup='mean').${var.http_5xx_requests_time_aggregator}.mean(by=['aws_region','namespace'])
			B = data('Count', rollup='mean').${var.http_5xx_requests_time_aggregator}.mean(by=['aws_region','namespace'])
      signal = (A/(B + ${var.artificial_requests_count})).scale(100)

      detect(when(signal > ${var.http_5xx_requests_threshold_critical}, max('${var.http_5xx_requests_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.http_5xx_requests_message, var.message)
		severity = "Critical"
	}

}

# Monitoring API Gateway 4xx errors percent
resource "signalfx_monitor" "API_http_4xx_errors_count" {
  count   = var.http_4xx_requests_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] API Gateway HTTP 4xx errors {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
    ${var.http_4xx_requests_time_aggregator}(${var.http_4xx_requests_timeframe}):
      default(avg:aws.apigateway.4xxerror{${var.filter_tags}} by {region,apiname,stage}.as_rate(), 0) / (
      default(avg:aws.apigateway.count{${var.filter_tags}} by {region,apiname,stage}.as_rate() + ${var.artificial_requests_count}, 1))
      * 100 > ${var.http_4xx_requests_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      A = data('4XXError', rollup='mean').${var.http_4xx_requests_time_aggregator}.mean(by=['aws_region','namespace'])
			B = data('Count', rollup='mean').${var.http_4xx_requests_time_aggregator}.mean(by=['aws_region','namespace'])
      signal = (A/(B + ${var.artificial_requests_count})).scale(100)

      detect(when(signal > ${var.http_4xx_requests_threshold_critical}, max('${var.http_4xx_requests_timeframe}'))).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.http_4xx_requests_message, var.message)
		severity = "Critical"
	}

}
