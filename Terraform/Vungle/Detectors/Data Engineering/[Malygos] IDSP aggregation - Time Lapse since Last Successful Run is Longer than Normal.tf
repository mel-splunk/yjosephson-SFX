# [Malygos] IDSP aggregation - Time Lapse since Last Successful Run is Longer than Normal
resource "signalfx_detector" "[Malygos] IDSP aggregation - Time Lapse since Last Successful Run is Longer than Normal" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] IDSP aggregation - Time Lapse since Last Successful Run is Longer than Normal"
  description = "TIme lapsed since last *successful* Malygos IDSP aggregation run"

/*  query = <<EOQ
    max(last_5m):max:custom.atf.malygos.idsp.aggregation.last.successful.run{*} + 5 >= 60
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.idsp.aggregation.success', rollup='max').max(over='5m') + 5

			detect(when(signal >= 60)).publish('CRIT')

  EOF

	rule {
		description = "Max >= 60 for last 5m"
		severity = "Critical"
	}

}
