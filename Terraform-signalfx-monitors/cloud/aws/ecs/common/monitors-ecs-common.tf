# Monitors related to services
resource "signalfx_detector" "service_cpu_utilization" {
	name = "ECS Service CPU Utilization High"

	program_text = <<-EOF
		signal = data('CPUUtilization', filter=filter('namespace', 'AWS/ECS')).mean(by=['aws_region','ServiceName']).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "service_memory_utilization" {
	name = "ECS Service Memory Utilization High"

	program_text = <<-EOF
		signal = data('MemoryUtilization', filter=filter('namespace', 'AWS/ECS')).mean(by=['aws_region','ServiceName']).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "service_missing_tasks" {
	name = "ECS Service not healthy enough"

	/*query = <<EOQ
	min last 5m
		avg:aws.ecs.service.running{${var.filter_tags}} by {region,servicename} / avg:aws.ecs.service.desired{${var.filter_tags}} by {region,servicename}
	* 100 < 60
	EOQ*/

	program_text = <<-EOF
		A = data('CPUReservation', filter=filter('namespace', 'AWS/ECS')).mean(by=['aws_region','ServiceName']) /* service running */
		/*B = data('XXX', filter=filter('namespace', 'AWS/ECS')).mean(by=['aws_region','ServiceName'])*/ /* still need to figure out service desired */
		signal = (A).scale(100).min(over='5m')
		detect(when(signal < 60)).publish('CRIT')
	EOF

	rule {
		description = "Min < 60 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
