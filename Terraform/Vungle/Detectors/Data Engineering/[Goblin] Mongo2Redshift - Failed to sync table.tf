# [Goblin] Mongo2Redshift - Failed to sync table
resource "signalfx_detector" "[Goblin] Mongo2Redshift - Failed to sync table" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] Mongo2Redshift - Failed to sync table"
  description = "The last attempt to sync MongoDB collection to Redshift Cheezit dimension tables saw failure. Failure to sync table between Mongo and Redshift detected earlier has recovered"

/*  query = <<EOQ
    min(last_1h):avg:cheezit.mongo2redshift.prod.failed_tables{*} > 1
  EOQ*/

  program_text = <<-EOF
      signal = data('cheezit.mongo2redshift.failed_tables').min(over='1h')
			
			detect(when(signal > 1 )).publish('CRIT')

  EOF

	rule {
		description = "Min > 1 for last 1hr"
		severity = "Critical"
	}

}
