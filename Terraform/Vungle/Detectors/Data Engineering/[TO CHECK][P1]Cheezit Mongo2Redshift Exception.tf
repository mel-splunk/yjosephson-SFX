# [TO CHECK][P1]Cheezit Mongo2Redshift Exception
resource "signalfx_detector" "to_check_p1_cheezit_mongo2redshift_exception" {
	count = "1"
	name = "[TO CHECK][P1]Cheezit Mongo2Redshift Exception"
	description = "Python pipeline which sync data from MongoDB cheezit database"

	program_text = <<-EOF
		signal = data('cheezit.mongo2redshift.excpetions', filter=filter('environment', 'prod'), rollup='average').min(over='5m')
		detect(when(signal > 100)).publish('CRIT')
	EOF

	rule {
		description = "Min > 100 for last 5m"
		severity = "Critical"
		detect_label = "Processing messages last 5m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
