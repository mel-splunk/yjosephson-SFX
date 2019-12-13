# [Malygos] EDSP Auctions - Ingestion - Number of Successful Job is Less than SLO
resource "signalfx_detector" "malygos_edsp_auctions_ingestion_number_of_successful_job_is_less_than_slo" {
	name = "[Malygos] EDSP Auctions - Ingestion - Number of Successful Job is Less than SLO"
	description = "[Malygos] EDSP Auctions - Ingestion - Number of Successful Job is Less than SLO"

	program_text = <<-EOF
		signal = data('malygos.edsp_auctions.ingestion.success', rollup='max').sum(over='1m') + 30
		detect(when(signal >= 40)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum >= 40 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
