# [Meister] AdBuilder (EKS+GKE) is not meeting Latency SLO
resource "signalfx_detector" "meister_adbuilder_eks_gke_is_not_meeting_latency_slo" {
	name = "[Meister] AdBuilder (EKS+GKE) is not meeting Latency SLO"
	description = "AdBuilder is taking too long to respond"

	program_text = <<-EOF
		signal = data('dsp.meister.adbuilder.request.duration.95percentile', filter=filter('environment', 'api-gke'), rollup='average').mean(over='5m')
		detect(when(signal >= 40)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average >= 40 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
