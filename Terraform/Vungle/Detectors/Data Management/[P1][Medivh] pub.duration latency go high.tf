# [P1][Medivh] pub.duration latency go high
resource "signalfx_detector" "p1_medivh_pub_duration_latency_go_high" {
	name = "[P1][Medivh] pub.duration latency go high"
	description = "This is monitoring the total number of milliseconds spent in the hot path of handling external publisher report endpoint."

	program_text = <<-EOF
		signal = data('report.medivh.external.endpoint.ext.pub.time.95percentile', filter=filter('environment', 'prod'), rollup='average').mean(over='5m')
		detect(when(signal > 30000 )).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average > 30000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
