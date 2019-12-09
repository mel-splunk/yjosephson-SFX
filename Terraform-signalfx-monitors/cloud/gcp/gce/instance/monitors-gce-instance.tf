#
# CPU Utilization
#
resource "signalfx_monitor" "cpu_utilization" {
  count   = var.cpu_utilization_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Compute Engine instance CPU Utilization {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
  ${var.cpu_utilization_time_aggregator}(${var.cpu_utilization_timeframe}):
    avg:gcp.gce.instance.cpu.utilization{${var.filter_tags}} by {instance_name} * 100
  > ${var.cpu_utilization_threshold_critical}
  EOQ*/

  program_text = <<-EOF
      signal = data('instance/cpu/utilization', rollup='mean').${var.cpu_utilization_time_aggregator}.mean(by=['instance_name']).scale(100)
			
			detect(when(signal > ${var.cpu_utilization_threshold_critical}, ${var.cpu_utilization_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.cpu_utilization_message, var.message)
		severity = "Critical"
	}

}

#
# Disk Throttled Bps
#
resource "signalfx_monitor" "disk_throttled_bps" {
  count   = var.disk_throttled_bps_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Compute Engine instance Disk Throttled Bps {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
  ${var.disk_throttled_bps_time_aggregator}(${var.disk_throttled_bps_timeframe}):
    (
      sum:gcp.gce.instance.disk.throttled_read_bytes_count{${var.filter_tags}} by {instance_name, device_name} +
      sum:gcp.gce.instance.disk.throttled_write_bytes_count{${var.filter_tags}} by {instance_name, device_name}
    ) / (
      sum:gcp.gce.instance.disk.read_bytes_count{${var.filter_tags}} by {instance_name, device_name} +
      sum:gcp.gce.instance.disk.write_bytes_count{${var.filter_tags}} by {instance_name, device_name}
    ) * 100
    > ${var.disk_throttled_bps_threshold_critical}
  EOQ*/

 program_text = <<-EOF
      A = data('instance/disk/throttled_read_bytes_count', rollup='sum').${var.disk_throttled_bps_time_aggregator}.sum(by=['instance_name','device_name'])
			B = data('instance/disk/throttled_write_bytes_count', rollup='sum').${var.disk_throttled_bps_time_aggregator}.sum(by=['instance_name','device_name'])
			C = data('instance/disk/read_bytes_count', rollup='sum').${var.disk_throttled_bps_time_aggregator}.sum(by=['instance_name','device_name'])
			D = data('instance/disk/write_bytes_count', rollup='sum').${var.disk_throttled_bps_time_aggregator}.sum(by=['instance_name','device_name'])
			
      signal = ((A + B)/ (C + D)).scale(100)
			detect(when(signal > ${var.disk_throttled_bps_threshold_critical}, ${var.disk_throttled_bps_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.disk_throttled_bps_message, var.message)
		severity = "Critical"
	}

}

#
# Disk Throttled OPS
#
resource "signalfx_monitor" "disk_throttled_ops" {
  count   = var.disk_throttled_ops_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Compute Engine instance Disk Throttled OPS {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

  /*query = <<EOQ
  ${var.disk_throttled_ops_time_aggregator}(${var.disk_throttled_ops_timeframe}):
    (
      sum:gcp.gce.instance.disk.throttled_read_ops_count{${var.filter_tags}} by {instance_name, device_name} +
      sum:gcp.gce.instance.disk.throttled_write_ops_count{${var.filter_tags}} by {instance_name, device_name}
    ) / (
      sum:gcp.gce.instance.disk.read_ops_count{${var.filter_tags}} by {instance_name, device_name} +
      sum:gcp.gce.instance.disk.write_ops_count{${var.filter_tags}} by {instance_name, device_name}
    ) * 100
    > ${var.disk_throttled_ops_threshold_critical}
  EOQ*/

 program_text = <<-EOF
      A = data('instance/disk/throttled_read_ops_count', rollup='sum').${var.disk_throttled_ops_time_aggregator}.sum(by=['instance_name','device_name'])
			B = data('instance/disk/throttled_write_ops_count', rollup='sum').${var.disk_throttled_ops_time_aggregator}.sum(by=['instance_name','device_name'])
			C = data('instance/disk/read_ops_count', rollup='sum').${var.disk_throttled_ops_time_aggregator}.sum(by=['instance_name','device_name'])
			D = data('instance/disk/write_ops_count', rollup='sum').${var.disk_throttled_ops_time_aggregator}.sum(by=['instance_name','device_name'])
			
      signal = ((A + B)/ (C + D)).scale(100)
			detect(when(signal > ${var.disk_throttled_ops_threshold_critical}, ${var.disk_throttled_ops_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.disk_throttled_ops_message, var.message)
		severity = "Critical"
	}

}
