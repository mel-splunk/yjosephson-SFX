# [P1][Malygos] edsp_auctions.ingestion failed to run in 30 minutes
resource "signalfx_detector" "p1_malygos_edsp_auctions_ingestion_failed_to_run_in_30_minutes" {
	count = "1"
	name = "[P1][Malygos] edsp_auctions.ingestion failed to run in 30 minutes"
	description = "Streaming pipeline which consumes data from kafka ex-jaeger-auction and as-reportAds topics and perform join on them and ship the results to cheezit edsp_auctions table. This table is used for further auction related business analytics."

	program_text = <<-EOF
		signal = data('malygos.edsp_auctions.ingestion.success', filter=filter('environment', 'prod'), rollup='average').sum(over='30m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Sum < 1 for last 30m"
		severity = "Critical"
		etect_label = "Processing messages last 1h"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
