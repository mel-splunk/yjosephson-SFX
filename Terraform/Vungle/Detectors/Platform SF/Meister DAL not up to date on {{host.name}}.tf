# Meister DAL not up to date on {{host.name}}
resource "signalfx_detector" "meister_dal_not_up_to_date_on_host_name" {
	name = "[Meister DAL not up to date on {{host.name}}"
	description = "Dal is not up to date on host"

	program_text = <<-EOF
		signal = data('dsp.meister.dal.update.error.count', rollup='max').max(by=['host']).min(over='2h')
		detect(when(signal >= 3)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Min >= 3 for last 2h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
