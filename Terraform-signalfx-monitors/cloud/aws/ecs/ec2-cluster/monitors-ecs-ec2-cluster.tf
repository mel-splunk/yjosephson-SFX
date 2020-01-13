# Monitors related to ECS Cluster
resource "signalfx_detector" "ecs_agent_status" {
	name = "ECS Agent disconnected"

	/*query = <<EOQ
		"aws.ecs.agent_connected"${module.filter-tags.service_check}.by("cluster","instance_id").last(6).count_by_status()
	EOQ*/

}

resource "signalfx_detector" "cluster_cpu_utilization" {
	name = "ECS Cluster CPU Utilization High"

	program_text = <<-EOF
		signal = data('CPUUtilization', filter=filter('namespace', 'AWS/ECS')).mean(by=['aws_region','ClusterName']).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "cluster_memory_reservation" {
	name = "ECS Cluster Memory Reservation High"

	program_text = <<-EOF
		signal = data('MemoryReservation', filter=filter('namespace', 'AWS/ECS')).mean(by=['aws_region','ClusterName']).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
