# [P1][Goblin] Update dynamic_campaign_installs encounter error
resource "signalfx_detector" "[P1][Goblin] Update dynamic_campaign_installs encounter error" {
  count = "${length(var.clusters)}"
  name    = "[P1][Goblin] Update dynamic_campaign_installs encounter error"
  description = "Batch pipeline which sync data from Cheezit dimension tables to S3 for Metamarket usage. The job runs once everyday. This alert is triggered when the job didn't run in 2 days."

/*  query = <<EOQ
    min(last_2h):avg:goblin.prod.update_redshift.update_dynamic_campaign_installs.success{*} < 1
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.update_redshift.update_dynamic_campaign_installs.success', rollup='average').min(over='2h')

			detect(when(signal < 1)).publish('CRIT')

  EOF

	rule {
		description = "Min < 1 for last 2h"
		severity = "Critical"
	}

}
