# [Temporary][Nostradamus][datasci] datasci.model_updates table stale for 4 hours
resource "signalfx_detector" "temporary_nostradamus_datasci_datasci_model_updates_table_stale_for_4_hours" {
	name = "[Temporary][Nostradamus][datasci] datasci.model_updates table stale for 4 hours"
	description = "Table has not been updated since last 4 hours"

	program_text = <<-EOF
		signal = data('UpdateFlatCPMFloorTaskAgeSeconds', filter=filter('namespace', 'nostradamus'), rollup='average').max(over='30m')
		detect(when(signal > 14000)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max > 14000 for last 30m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
