# [Goblin] Redshift to Memsql - Sync advertiser report processing too little data
resource "signalfx_detector" "[Goblin] Redshift to Memsql - Sync advertiser report processing too little data" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] Redshift to Memsql - Sync advertiser report processing too little data"
  description = "Sync advertiser report processing too little data"

/*  query = <<EOQ
    avg(last_1h):avg:goblin.prod.redshift2memsql.advertiser_report_column.rows{*} < 50000
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.redshift2memsql.advertiser_report_column.rows', rollup='average').mean(over='1h')
			
			detect(when(signal < 50000)).publish('CRIT')

  EOF

	rule {
		description = "Count < 50000 for last 1h"
		severity = "Critical"
	}

}
