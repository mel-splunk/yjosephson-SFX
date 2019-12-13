# [Nostradamus][datasci] datasci.model_updates table stale for 4 hours
resource "signalfx_detector" "nostradamus_datasci_datasci_model_updates_table_stale_for_4_hours" {
	name = "[Nostradamus][datasci] datasci.model_updates table stale for 4 hours"
	description = "Table has not been updated since last 4 hours"

	program_text = <<-EOF
		signal = data('FlatCPMUpdateLast4Hours', filter=filter('namespace', 'Redshift'), rollup='average').max(over='1h')
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max <= 0 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
