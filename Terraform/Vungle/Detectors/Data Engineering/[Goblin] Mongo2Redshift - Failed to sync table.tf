# [Goblin] Mongo2Redshift - Failed to sync table
resource "signalfx_detector" "goblin_mongo2redshift_failed_to_sync_table" {
	name = "[Goblin] Mongo2Redshift - Failed to sync table"
	description = "The last attempt to sync MongoDB collection to Redshift Cheezit dimension tables saw failure. Failure to sync table between Mongo and Redshift detected earlier has recovered"

	program_text = <<-EOF
		signal = data('cheezit.mongo2redshift.failed_tables', rollup='average').min(over='1h')
		detect(when(signal > 1 )).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description   = "Min > 1 for last 1hr"
		severity      = "Critical"
		detect_label  = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
