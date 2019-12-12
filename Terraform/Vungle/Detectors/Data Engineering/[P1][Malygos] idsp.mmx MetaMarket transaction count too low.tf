# [P1][Malygos] idsp.mmx MetaMarket transaction count too low
resource "signalfx_detector" "[P1][Malygos] idsp.mmx MetaMarket transaction count too low" {
  count = "${length(var.clusters)}"
  name    = "[P1][Malygos] idsp.mmx MetaMarket transaction count too low"
  description = "Batch pipeline which loads data from cheezit idsp_transactions table and perform ETL on them and ship the results to S3 vungle-mmx-share/gallywix/mmx bucket so that MMX could pick them up and show the results on their dashboard."

/*  query = <<EOQ
    max(last_4h):avg:malygos.idsp.mmx.transactions{env:prod} < 1000000
  EOQ*/

  program_text = <<-EOF
      signal = data('malygos.idsp.mmx.transactions', filter=filter('environment', 'prod'), rollup='average').max(over='4h')

			detect(when(signal < 1000000)).publish('CRIT')

  EOF

	rule {
		description = "Max < 1000000 for last 4h"
		severity = "Critical"
	}

}
