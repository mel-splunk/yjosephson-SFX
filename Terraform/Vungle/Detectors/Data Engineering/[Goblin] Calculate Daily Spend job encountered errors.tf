# [Goblin] Calculate Daily Spend job encountered errors
resource "signalfx_detector" "[Goblin] Calculate Daily Spend job encountered errors" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] Calculate Daily Spend job encountered errors"
  description = "*What happened*\n Error encountered when trying to move dailySpent report data from MemSQL to MongoDB \nNo more new error encountered when trying to move dailySpent report data from MemSQL to MongoDB"

/*  query = <<EOQ
    max(last_2h):avg:goblin.prod.dailySpent.mongodb.errors{*} > 1
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.dailySpent.mongodb.errors').mean(by=['sf_metric']).max(over='2h')
			
			detect(when(signal > 1)).publish('CRIT')

  EOF

	rule {
		description = "maximum > 1 for last 2hr"
		severity = "Critical"
	}

}
