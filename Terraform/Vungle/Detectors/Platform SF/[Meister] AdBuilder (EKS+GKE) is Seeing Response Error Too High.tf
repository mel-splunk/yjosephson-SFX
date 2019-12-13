# [Meister] AdBuilder (EKS+GKE) is Seeing Response Error Too High
resource "signalfx_detector" "meister_adbuilder_eks_gke_is_seeing_response_error_too_high" {
	name = "[Meister] AdBuilder (EKS+GKE) is Seeing Response Error Too High"
	description = "Adbuilder is experiencing elevated error rate that is above the healthy threshold"

	program_text = <<-EOF
		A = data('dsp.meister.adbuilder.error.count', filter=filter('environment', 'api-gke'), rollup='rate').mean()
		B = data('dsp.meister.adbuilder.request.count', filter=filter('environment', 'api-gke'), rollup='rate').mean()
		signal = (A/B).scale(100).mean(over='10m')
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
