# [Spark2] Jobs Running Is Too Low
resource "signalfx_detector" "spark2_jobs_running_is_too_low" {
	count = "1"
	name = "[Spark2] Jobs Running Is Too Low"
	description = "[Spark2] Jobs Running Is Too Low"

	program_text = <<-EOF
		signal = data('gauge.spark.job.num_active_tasks', filter=filter('cluster_name', 'spark2-prod'), rollup='sum').sum(over='5m').count()
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	rule {
		description = "Sum <= 0 for last 5m"
		severity = "Critical"
		detect_label = "Processing messages last 5m"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
