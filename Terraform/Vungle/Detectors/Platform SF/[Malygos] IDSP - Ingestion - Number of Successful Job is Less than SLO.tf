# [Malygos] IDSP - Ingestion - Number of Successful Job is Less than SLO
resource "signalfx_detector" "malygos_idsp_ingestion_number_of_successful_job_is_less_than_slo" {
	name = "[Malygos] IDSP - Ingestion - Number of Successful Job is Less than SLO"
	description = "Number of successful job run is less than SLO"

	program_text = <<-EOF
		signal = data('malygos.idsp.ingestion.success', rollup='max').sum(over='1m')
		detect(when(signal >= 10)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum >= 10 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
