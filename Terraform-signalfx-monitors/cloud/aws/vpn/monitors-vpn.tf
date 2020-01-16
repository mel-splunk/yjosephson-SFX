resource "signalfx_detector" "VPN_status" {
	name = "VPN tunnel down"

	/*query = <<EOQ
				${var.vpn_status_time_aggregator}(${var.vpn_status_timeframe}): (
					min:aws.vpn.tunnel_state{${var.filter_tags}} by {region,tunnelipaddress}
				) < 1
	EOQ*/

	program_text = <<-EOF
		/* Currently SFx doesn't have AWS/VPN so need to revisit this */
		signal = data('TunnelState', filter=filter('namespace', 'AWS/VPN')).min(by=['aws_region','TunnerIPAddress']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum > 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
