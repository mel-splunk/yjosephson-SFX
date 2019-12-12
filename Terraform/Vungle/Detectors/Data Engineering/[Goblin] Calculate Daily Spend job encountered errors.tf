# [Goblin] Calculate Daily Spend job encountered errors
resource "signalfx_detector" "goblin_calculate_daily_spend_job_encountered_errors" {
  count = "1"
  name    = "[Goblin] Calculate Daily Spend job encountered errors"
  description = "*What happened*\n Error encountered when trying to move dailySpent report data from MemSQL to MongoDB \nNo more new error encountered when trying to move dailySpent report data from MemSQL to MongoDB"

  program_text = <<-EOF
      signal = data('goblin.dailySpent.mongodb.errors').mean(by=['sf_metric']).max(over='2h')
			
			detect(when(signal > 1)).publish('CRIT')

  EOF

	rule {
		description = "maximum > 1 for last 2hr"
		severity = "Critical"
		detect_label = "Processing messages last 2hr"
        	notifications = ["Email,foo-alerts@bar.com"]
	}

}
