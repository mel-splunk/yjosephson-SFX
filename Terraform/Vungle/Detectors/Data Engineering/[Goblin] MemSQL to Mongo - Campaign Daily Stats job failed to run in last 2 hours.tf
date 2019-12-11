# [Goblin] MemSQL to Mongo - Campaign Daily Stats job failed to run in last 2 hours
resource "signalfx_detector" "[Goblin] MemSQL to Mongo - Campaign Daily Stats job failed to run in last 2 hours" {
  count = "${length(var.clusters)}"
  name    = "[Goblin] MemSQL to Mongo - Campaign Daily Stats job failed to run in last 2 hours"
  description = "This job that moves data from MemSQL (*advertiser_report_daily*) to MongoDB (*dailyStats*) failed to run. This job that moves data from MemSQL (*advertiser_report_daily*) to MongoDB (*dailyStats*) that failed to run is recovering"

/*  query = <<EOQ
    events('priority:all \"data_goblin_calc_dailystats_prod build succeeded\"').rollup('count').last('2h') < 1
  EOQ*/

  program_text = <<-EOF
      signal = data('goblin.dailystats.total_count', rollup='count').sum(over='2h')
			
			detect(when(signal < 1 )).publish('CRIT')

  EOF

	rule {
		description = "Count < 1 for last 2hr"
		severity = "Critical"
	}

}
