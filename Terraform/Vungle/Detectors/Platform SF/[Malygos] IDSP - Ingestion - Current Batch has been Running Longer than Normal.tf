# [Malygos] IDSP - Ingestion - Current Batch has been Running Longer than Normal
resource "signalfx_detector" "malygos_idsp_ingestion_current_batch_has_been_running_longer_than_normal" {
	name = "[Malygos] IDSP - Ingestion - Current Batch has been Running Longer than Normal"
	description = "The current IDSP ingestion batch has now been running for sometime which will likely lead to SLO violation"

	program_text = <<-EOF
		signal = data('malygos.idsp.ingestion.batch.start', rollup='max').sum(over='1m')
		detect(when(signal >= 30)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Sum >= 30 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
