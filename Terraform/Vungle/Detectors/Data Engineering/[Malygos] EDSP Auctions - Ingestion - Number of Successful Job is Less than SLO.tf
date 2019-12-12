# [Malygos] EDSP Auctions - Ingestion - Number of Successful Job is Less than SLO
resource "signalfx_detector" "malygos_edsp_auctions_ingestion_number_of_successful_job_is_less_than_slo" {
	count = "1"
	name = "[Malygos] EDSP Auctions - Ingestion - Number of Successful Job is Less than SLO"
	description = "Number of successful job run is less than SLO."

	program_text = <<-EOF
		signal = data('malygos.edsp_auctions.ingestion.success', rollup='max').min(over='1m') + 30
		detect(when(signal >= 40)).publish('CRIT')
	EOF

	rule {
		description = "Min >= 40 for last 1m"
		severity = "Critical"
		detect_label = "Processing messages last 1m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
