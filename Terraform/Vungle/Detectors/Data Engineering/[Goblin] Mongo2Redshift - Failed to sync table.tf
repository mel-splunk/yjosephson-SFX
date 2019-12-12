# [Goblin] Mongo2Redshift - Failed to sync table
resource "signalfx_detector" "goblin_mongo2redshift_failed_to_sync_table" {
  count = "1"
  name = "[Goblin] Mongo2Redshift - Failed to sync table"
  description = "The last attempt to sync MongoDB collection to Redshift Cheezit dimension tables saw failure. Failure to sync table between Mongo and Redshift detected earlier has recovered"

  program_text = <<-EOF
    signal = data('cheezit.mongo2redshift.failed_tables', rollup='average').min(over='1h')
    detect(when(signal > 1 )).publish('CRIT')
  EOF

  rule {
    description   = "Min > 1 for last 1hr"
    severity      = "Critical"
    detect_label  = "Processing messages last 1hr"
    notifications = ["Email,foo-alerts@bar.com"]
  }

}
