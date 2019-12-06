resource "signalfx_monitor" "VPN_status" {
  count   = var.vpn_status_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] VPN tunnel down"
  message = coalesce(var.vpn_status_message, var.message)
  type    = "query alert"

  /*query = <<EOQ
        ${var.vpn_status_time_aggregator}(${var.vpn_status_timeframe}): (
          min:aws.vpn.tunnel_state{${var.filter_tags}} by {region,tunnelipaddress}
        ) < 1
  EOQ*/

  program_text = <<-EOF
    /* Currently SFx doesn't have AWS/VPN so need to revisit this */
      signal = data('TunnelState', filter=filter('namespace', 'AWS/VPN'), rollup='min').${var.vpn_status_time_aggregator}.min(by=['aws_region','TunnerIPAddress'])
			
			detect(when(signal < 1).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.vpn_status_message, var.message)
		severity = "Critical"
	}

}
