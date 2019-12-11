# [Malygos] IDSP ingestion - Time Lapse since Last Successful Run is Longer than Normal
resource "signalfx_detector" "[Malygos] IDSP ingestion - Time Lapse since Last Successful Run is Longer than Normal" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] IDSP ingestion - Time Lapse since Last Successful Run is Longer than Normal"
  description = "TIme lapsed since last *successful* Malygos IDSP ingestion run"

/*  query = <<EOQ
    max(last_5m):max:custom.atf.malygos.idsp.ingestion.last.successful.run{*} + 5 >= 50
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.idsp.ingestion.success', rollup='max').max(over='5m') + 5

			detect(when(signal >= 50)).publish('CRIT')

  EOF

	rule {
		description = "Max >= 50 for last 5m"
		severity = "Critical"
	}

}
