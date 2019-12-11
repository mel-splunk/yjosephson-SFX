# [Goblin] Mongo2Redshift - Zero successful run to update dimension tables detected
resource "signalfx_detector" "[Goblin] Mongo2Redshift - Zero successful run to update dimension tables detected" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] Mongo2Redshift - Zero successful run to update dimension tables detected"
  description = "Jenkins job that updates dimension tables in Redshift Cheezit failed to complete in last 2 hours. New Jenkins job completion detected in last 2 hours"

/*  query = <<EOQ
    events('priority:all \"data_goblin_cheezit_mongo2redshift_prod build succeeded\"').rollup('count').last('4h') < 1
  EOQ*/

  program_text = <<-EOF
      signal = data('cheezit.mongo2redshift.success_tables', rollup='count').sum(over='4h')
			
			detect(when(signal < 1 )).publish('CRIT')

  EOF

	rule {
		description = "Count < 1 for last 4hr"
		severity = "Critical"
	}

}
