resource "signalfx_detector" "mongodb_primary" {
	name = "MongoDB primary state"

	/*query = <<EOQ
			${var.mongodb_primary_aggregator}(${var.mongodb_primary_timeframe}):
			min:mongodb.replset.state${module.filter-tags.query_alert} by {replset_name} >= 2
EOQ

	program_text = <<-EOF
		signal = data('XXX', filter=filter('plugin', 'mongo')).min(by=['replset_name']).max(over='1m')
		detect(when(signal >= 2)).publish('CRIT')
	EOF

	rule {
		description = "Max >= 2 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "mongodb_secondary" {
	name = "MongoDB secondary missing"

	/*query = <<EOQ
			${var.mongodb_secondary_aggregator}(${var.mongodb_secondary_timeframe}):
			${var.mongodb_desired_servers_count} -
			sum:mongodb.replset.health${module.filter-tags.query_alert} by {replset_name}
			> 1
EOQ

	program_text = <<-EOF
		A = data('XXX', filter=filter('plugin', 'mongo')).sum(by=['replset_name'])
		signal = (3-A).max(over='5m')
		detect(when(signal > 1)).publish('CRIT')
	EOF

	rule {
		description = "Max > 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "mongodb_server_count" {
	name = "MongoDB too much servers or wrong monitoring config"

	/*query = <<EOQ
			${var.mongodb_server_count_aggregator}(${var.mongodb_server_count_timeframe}):
			sum:mongodb.replset.health${module.filter-tags.query_alert} by {replset_name}
			> 99
EOQ

	program_text = <<-EOF
		signal = data('XXX', filter=filter('plugin', 'mongo')).sum(by=['replset_name']).min(over='15m')
		detect(when(signal > 99)).publish('CRIT')
	EOF

	rule {
		description = "Max > 99 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/
}

resource "signalfx_detector" "mongodb_replication" {
	name = "MongoDB replication lag"

	program_text = <<-EOF
		signal = data('gauge.repl.max_lag', filter=filter('plugin', 'mongo') and filter('replset_state', 'secondary')).mean(by=['server']).mean(over='1m')
		detect(when(signal > 5)).publish('CRIT')
	EOF

	rule {
		description = "Average > 5 for last 1m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
