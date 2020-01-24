#
# Service Check
#
resource "signalfx_detector" "not_responding" {
	name    = "Kong does not respond"

	/*query = <<EOQ
		"kong.can_connect"${module.filter-tags.service_check}.by("kong_host","kong_port").last(6).count_by_status()
EOQ*/

}

resource "signalfx_detector" "treatment_limit" {
	name = "Kong exceeded its treatment limit"

	program_text = <<-EOF
		A = data('counter.kong.connections.handled', filter=filter('plugin', 'kong')).min(by=['host'])
		B = data('counter.kong.connections.accepted', filter=filter('plugin', 'kong')).min(by=['host'])
		signal = ((A-B)/A).scale(100).min(over='15m')
		detect(when(signal > 20)).publish('CRIT')
	EOF

	rule {
		description = "Min > 20 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
