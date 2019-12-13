# [Malygos] IDSP aggregation - Time Lapse since Last Successful Run is Longer than Normal
resource "signalfx_detector" "malygos_idsp_aggregation_time_lapse_since_last_successful_run_is_longer_than_normal" {
	name = "[Malygos] IDSP aggregation - Time Lapse since Last Successful Run is Longer than Normal"
	description = "Time has lapsed since last successful Malygos IDSP aggregation run"

	program_text = <<-EOF
		signal = data('malygos.idsp.aggregation.success', rollup='max').max(over='5m') + 5
		detect(when(signal >= 60)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max >= 60 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
