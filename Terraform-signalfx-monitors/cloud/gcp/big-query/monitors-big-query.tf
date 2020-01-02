#
# Concurrent queries
#
resource "signalfx_detector" "concurrent_queries" {
	name = "GCP Big Query Concurrent Queries"

	program_text = <<-EOF
		signal = data('query/count').mean(by=['project_id']).mean(over='5m')
		detect(when(signal > 45)).publish('CRIT')
	EOF

	rule {
		description = "Average > 45 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Execution Time
#
resource "signalfx_detector" "execution_time" {
	name = "GCP Big Query Execution Time"

	program_text = <<-EOF
		signal = data('query/execution_times').mean(by=['project_id']).mean(over='5m')
		detect(when(signal > 150)).publish('CRIT')
	EOF

	rule {
		description = "Average > 150 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Scanned Bytes
#
resource "signalfx_detector" "scanned_bytes" {
	name = "GCP Big Query Scanned Bytes"

	program_text = <<-EOF
		signal = data('query/scanned_bytes', rollup='mean').mean(over='4h')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Average > 1 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Scanned Bytes Billed
#
resource "signalfx_detector" "scanned_bytes_billed" {
	name = "GCP Big Query Scanned Bytes Billed"

	program_text = <<-EOF
		signal = data('query/scanned_bytes_billed', rollup='mean').mean(over='4h')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Average > 1 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Available Slots
#
resource "signalfx_detector" "available_slots" {
	name = "GCP Big Query Available Slots"

	program_text = <<-EOF
		signal = data('slots/total_available', rollup='mean').mean(over='5m')
		detect(when(signal > 200)).publish('CRIT')
	EOF

	rule {
		description = "Average > 200 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Stored Bytes
#
resource "signalfx_detector" "stored_bytes" {
	name = "GCP Big Query Stored Bytes"

	program_text = <<-EOF
		signal = data('storage/stored_bytes', extrapolation='zero').mean(by=['project_id', 'table']).mean(over='5m')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Average > 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Table Count
#
resource "signalfx_detector" "table_count" {
	name = "GCP Big Query Table Count"

	program_text = <<-EOF
		signal = data('storage/table_count').mean(by=['dataset_id']).mean(over='4h')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Average > 1 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Uploaded Bytes
#
resource "signalfx_detector" "uploaded_bytes" {
	name = "GCP Big Query Uploaded Bytes"

	program_text = <<-EOF
		signal = data('storage/uploaded_bytes', extrapolation='zero').mean(by=['dataset_id', 'table']).mean(over='4h')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Average > 1 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

#
# Uploaded Bytes Billed
#
resource "signalfx_detector" "uploaded_bytes_billed" {
	name = "GCP Big Query Uploaded Bytes Billed"

	program_text = <<-EOF
		signal = data('storage/uploaded_bytes_billed', extrapolation='zero').mean(by=['dataset_id', 'table']).mean(over='4h')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Average > 1 for last 4h"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
