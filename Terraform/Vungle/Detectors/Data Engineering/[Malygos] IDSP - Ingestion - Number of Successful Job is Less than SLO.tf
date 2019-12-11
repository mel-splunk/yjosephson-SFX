# [Malygos] IDSP - Ingestion - Number of Successful Job is Less than SLO
resource "signalfx_detector" "[Malygos] IDSP - Ingestion - Number of Successful Job is Less than SLO" {
  count = "${length(var.clusters)}"
  name    = "[Malygos] IDSP - Ingestion - Number of Successful Job is Less than SLO"
  description = "Number of successful job run is less than SLO."

/*  query = <<EOQ
    sum(last_1m):max:custom.atf.malygos.idsp.ingestion.success{*} >= 10
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.idsp.ingestion.success', rollup='max').sum(over='1m')
      
			detect(when(signal >= 10)).publish('CRIT')

  EOF

	rule {
		description = "Sum >= 10 for last 1m"
		severity = "Critical"
	}

}
