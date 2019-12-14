# [Goblin] Sync publisher buyout count too low!
resource "signalfx_detector" "goblin_sync_publisher_buyout_count_too_low" {
	name = "[Goblin] Sync publisher buyout count too low!"
	description = "The job sync publisher buyout to memsql by overridding all instead of upsert, run daily"

	program_text = <<-EOF
		signal = data('goblin.redshift2memsql.publisher_buyout_clearing_cpm.rows', rollup='average').mean(over='1d')
		detect(when(signal < 100000)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average < 100000 for last 1d"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
