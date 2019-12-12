# [P1][Goblin] Update dynamic_campaign_installs encounter error
resource "signalfx_detector" "p1_goblin_update_dynamic_campaign_installs_encounter_error" {
	count = "1"
	name = "[P1][Goblin] Update dynamic_campaign_installs encounter error"
	description = "Batch pipeline which sync data from Cheezit dimension tables to S3 for Metamarket usage. The job runs once everyday. This alert is triggered when the job didn't run in 2 days."

	program_text = <<-EOF
		signal = data('goblin.update_redshift.update_dynamic_campaign_installs.success', rollup='average').min(over='2h')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Min < 1 for last 2h"
		severity = "Critical"
		detect_label = "Processing messages last 2h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
