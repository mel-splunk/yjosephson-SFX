resource "signalfx_detector" "datadog_nginx_process" {
	name = "Nginx vhost status does not respond"

	/*query = <<EOQ
		"nginx.can_connect"${module.filter-tags.service_check}.by("server","port").last(6).count_by_status()
EOQ*/

}

resource "signalfx_detector" "nginx_dropped_connections" {
	name = "Nginx dropped connections"

	program_text = <<-EOF
		signal = data('connections.failed', filter=filter('plugin', 'nginx')).mean(by=['host']).min(over='5m')
		detect(when(signal > 0)).publish('CRIT')
	EOF

	rule {
		description = "Min > 0 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

