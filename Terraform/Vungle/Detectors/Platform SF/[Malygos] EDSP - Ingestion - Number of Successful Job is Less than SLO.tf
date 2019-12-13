# [Malygos] EDSP - Ingestion - Number of Successful Job is Less than SLO
resource "signalfx_detector" "malygos_edsp_ingestion_number_of_successful_job_is_less_than_slo" {
	name = "[Malygos] EDSP - Ingestion - Number of Successful Job is Less than SLO"
	description = "Number of successful job run is less than SLO"

	program_text = <<-EOF
		signal = data('malygos.edsp.ingestion.success', rollup='max').min(over='1m') + 30
		detect(when(signal >= 40)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Min >= 40 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
