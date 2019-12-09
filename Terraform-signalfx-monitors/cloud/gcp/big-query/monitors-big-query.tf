#
# Concurrent queries
#
resource "signalfx_monitor" "concurrent_queries" {
  count   = var.concurrent_queries_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Concurrent Queries {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
    avg(${var.concurrent_queries_timeframe}):
      default(avg:gcp.bigquery.query.count{${var.filter_tags}}, 0)
    > ${var.concurrent_queries_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('query/count', rollup='mean').mean(by=['project_id'])
			
			detect(when(signal > ${var.concurrent_queries_threshold_critical}, ${var.concurrent_queries_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.concurrent_queries_message, var.message)
		severity = "Critical"
	}

}

#
# Execution Time
#
resource "signalfx_monitor" "execution_time" {
  count   = var.execution_time_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Execution Time {{#is_alert}}{{{comparator}}} {{threshold}}s ({{value}}s){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}s ({{value}}s){{/is_warning}}"

  /*query = <<EOQ
    avg(${var.execution_time_timeframe}):
      default(avg:gcp.bigquery.query.execution_times.avg{${var.filter_tags}}, 0)
    > ${var.execution_time_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('query/execution_times', rollup='mean').mean(by=['project_id'])
			
			detect(when(signal > ${var.execution_time_threshold_critical}, ${var.execution_time_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.execution_time_message, var.message)
		severity = "Critical"
	}

}

#
# Scanned Bytes
#
resource "signalfx_monitor" "scanned_bytes" {
  count   = var.scanned_bytes_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Scanned Bytes {{#is_alert}}{{{comparator}}} {{threshold}}B/mn ({{value}}B/mn){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}B/mn ({{value}}B/mn){{/is_warning}}"

  /*query = <<EOQ
  avg(${var.scanned_bytes_timeframe}):
    default(avg:gcp.bigquery.query.scanned_bytes{${var.filter_tags}}, 0)
  > ${var.scanned_bytes_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('query/scanned_bytes', rollup='mean')
			
			detect(when(signal > ${var.scanned_bytes_threshold_critical}, ${var.scanned_bytes_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.scanned_bytes_message, var.message)
		severity = "Critical"
	}

}

#
# Scanned Bytes Billed
#
resource "signalfx_monitor" "scanned_bytes_billed" {
  count   = var.scanned_bytes_billed_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Scanned Bytes Billed {{#is_alert}}{{{comparator}}} {{threshold}}B/mn ({{value}}B/mn){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}B/mn ({{value}}B/mn){{/is_warning}}"

  /*query = <<EOQ
  avg(${var.scanned_bytes_billed_timeframe}):
    default(avg:gcp.bigquery.query.scanned_bytes_billed{${var.filter_tags}}, 0)
  > ${var.scanned_bytes_billed_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('query/scanned_bytes_billed', rollup='mean')
			
			detect(when(signal > ${var.scanned_bytes_billed_threshold_critical}, ${var.scanned_bytes_billed_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.scanned_bytes_billed_message, var.message)
		severity = "Critical"
	}

}

#
# Available Slots
#
resource "signalfx_monitor" "available_slots" {
  count   = var.available_slots_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Available Slots {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
    avg(${var.available_slots_timeframe}):
      avg:gcp.bigquery.slots.total_available{${var.filter_tags}}
    < ${var.available_slots_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('slots/total_available', rollup='mean')
			
			detect(when(signal > ${var.available_slots_threshold_critical}, ${var.available_slots_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.available_slots_message, var.message)
		severity = "Critical"
	}

}

#
# Stored Bytes
#
resource "signalfx_monitor" "stored_bytes" {
  count   = var.stored_bytes_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Stored Bytes {{#is_alert}}{{{comparator}}} {{threshold}}B ({{value}}B){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}B ({{value}}B){{/is_warning}}"

  /*query = <<EOQ
    avg(${var.stored_bytes_timeframe}):
      default(avg:gcp.bigquery.storage.stored_bytes{${var.filter_tags}} by {dataset_id,table}, 0)
    > ${var.stored_bytes_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('storage/stored_bytes', rollup='mean').mean(by=['project_id','table'])
			
			detect(when(signal > ${var.stored_bytes_threshold_critical}, ${var.stored_bytes_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.stored_bytes_message, var.message)
		severity = "Critical"
	}

}

#
# Table Count
#
resource "signalfx_monitor" "table_count" {
  count   = var.table_count_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Table Count {{#is_alert}}{{{comparator}}} {{threshold}} ({{value}}){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}} ({{value}}){{/is_warning}}"

  /*query = <<EOQ
  avg(${var.table_count_timeframe}):
    avg:gcp.bigquery.storage.table_count{${var.filter_tags}} by {dataset_id}
  > ${var.table_count_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('storage/table_count', rollup='mean').mean(by=['project_id'])
			
			detect(when(signal > ${var.table_count_threshold_critical}, ${var.table_count_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.table_count_message, var.message)
		severity = "Critical"
	}

}

#
# Uploaded Bytes
#
resource "signalfx_monitor" "uploaded_bytes" {
  count   = var.uploaded_bytes_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Uploaded Bytes {{#is_alert}}{{{comparator}}} {{threshold}}B/mn ({{value}}B/mn){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}B/mn ({{value}}B/mn){{/is_warning}}"

  /*query = <<EOQ
  avg(${var.uploaded_bytes_timeframe}):
    default(avg:gcp.bigquery.storage.uploaded_bytes{${var.filter_tags}} by {dataset_id,table}, 0)
  > ${var.uploaded_bytes_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('storage/uploaded_bytes', rollup='mean').mean(by=['project_id', 'table'])
			
			detect(when(signal > ${var.uploaded_bytes_threshold_critical}, ${var.uploaded_bytes_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.uploaded_bytes_message, var.message)
		severity = "Critical"
	}

}

#
# Uploaded Bytes Billed
#
resource "signalfx_monitor" "uploaded_bytes_billed" {
  count   = var.uploaded_bytes_billed_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] GCP Big Query Uploaded Bytes Billed {{#is_alert}}{{{comparator}}} {{threshold}}B/mn ({{value}}B/mn){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}B/mn ({{value}}B/mn){{/is_warning}}"

  /*query = <<EOQ
    avg(${var.uploaded_bytes_billed_timeframe}):
      default(avg:gcp.bigquery.storage.uploaded_bytes_billed{${var.filter_tags}} by {dataset_id,table}, 0)
    > ${var.uploaded_bytes_billed_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('storage/uploaded_bytes_billed', rollup='mean').mean(by=['project_id', 'table'])
			
			detect(when(signal > ${var.uploaded_bytes_billed_threshold_critical}, ${var.uploaded_bytes_billed_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.uploaded_bytes_billed_message, var.message)
		severity = "Critical"
	}

}
