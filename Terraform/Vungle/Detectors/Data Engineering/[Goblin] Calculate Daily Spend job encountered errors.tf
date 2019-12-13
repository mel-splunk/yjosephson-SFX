# [Goblin] Calculate Daily Spend job encountered errors
resource "signalfx_detector" "goblin_calculate_daily_spend_job_encountered_errors" {
	name = "[Goblin] Calculate Daily Spend job encountered errors"
	description = "Error encountered when trying to move dailySpent report data from MemSQL to MongoDB"

	program_text = <<-EOF
  		signal = data('goblin.dailySpent.mongodb.errors', rollup='average').max(over='2h')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "maximum > 1 for last 2hr"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
