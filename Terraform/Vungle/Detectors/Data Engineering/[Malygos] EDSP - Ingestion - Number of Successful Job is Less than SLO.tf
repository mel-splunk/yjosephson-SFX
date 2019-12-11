# [Malygos] EDSP - Ingestion - Number of Successful Job is Less than SLO
resource "signalfx_detector" "[Malygos] EDSP - Ingestion - Number of Successful Job is Less than SLO" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] EDSP - Ingestion - Number of Successful Job is Less than SLO"
  description = "Number of successful job run is returning to SLO level."

/*  query = <<EOQ
    min(last_1m):max:custom.atf.malygos.edsp.ingestion.success{*} + 30 >= 40
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.edsp.ingestion.success', rollup='max').min(over='1m') + 30
  
			detect(when(signal >= 40)).publish('CRIT')

  EOF

	rule {
		description = "Min >= 40 for last 1m"
		severity = "Critical"
	}

}
