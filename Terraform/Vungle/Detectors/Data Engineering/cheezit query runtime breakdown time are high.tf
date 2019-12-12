# cheezit query runtime breakdown time are high
resource "signalfx_detector" "cheezit query runtime breakdown time are high" {
	count = "1"
	name = "cheezit query runtime breakdown time are high"
	description = "Cheezit query runtime breakdown time are high"

	program_text = <<-EOF
		signal = data('goblin.redshift2memsql.hbs_report_daily.rows', filter=filter('namespace', 'AWS/Redshift') and filter('ClusterIdentifier', 'cheezit'), rollup='average').mean(over='30m')
		detect(when(signal > 2000000)).publish('CRIT')
	EOF

	rule {
		description = "Average > 2000000 for last 30m"
		severity = "Critical"
		detect_label = "Processing messages last 30m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
