#
# CPU Utilization
#
resource "signalfx_detector" "cpu_utilization" {
	name = "Compute Engine instance CPU Utilization"

	program_text = <<-EOF
		A = data('instance/cpu/utilization', filter=filter('resource_type', 'Microsoft.Web/sites')).mean(by=['instance_name'])
		signal = (A*100).mean(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Average > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Disk Throttled Bps
#
resource "signalfx_detector" "disk_throttled_bps" {
	name = "Compute Engine instance Disk Throttled Bps"

	program_text = <<-EOF
		A = data('instance/disk/throttled_read_bytes_count').sum(by=['instance_name','device_name'])
		B = data('instance/disk/throttled_write_bytes_count').sum(by=['instance_name','device_name'])
		C = data('instance/disk/read_bytes_count').sum(by=['instance_name','device_name'])
		D = data('instance/disk/write_bytes_count').sum(by=['instance_name','device_name'])
		signal = ((A + B)/ (C + D)).scale(100).min(over='15m')
		detect(when(signal > 50)).publish('CRIT')
	EOF

	rule {
		description = "Min > 50 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

#
# Disk Throttled OPS
#
resource "signalfx_detector" "disk_throttled_ops" {
	name = "Compute Engine instance Disk Throttled OPS"

	program_text = <<-EOF
		A = data('instance/disk/throttled_read_ops_count').sum(by=['instance_name','device_name'])
		B = data('instance/disk/throttled_write_ops_count').sum(by=['instance_name','device_name'])
		C = data('instance/disk/read_ops_count').sum(by=['instance_name','device_name'])
		D = data('instance/disk/write_ops_count').sum(by=['instance_name','device_name'])
		signal = ((A + B)/(C + D)).scale(100).min(over='15m')
		detect(when(signal > 50)).publish('CRIT')
	EOF

	rule {
		description = "Min > 50 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
