# Nostradamus Model (BCVR) is older than 4 hours
resource "signalfx_detector" "nostradamus_model_bcvr_is_older_than_4_hours" {
	name = "Nostradamus Model (BCVR) is older than 4 hours"
	description = "Nostradamus Model (BCVR) is older than 4 hours"

	program_text = <<-EOF
		signal = data('nostradamus.api_server.model_age', filter=filter('deployment', 'prod') and filter('model_name', 'nostradamus.ad_recommenders.common.cvr_upper_bound.beta_binomial_upper_bound.BetaBinomialUpperBoundModelBuilder_active_hours_24_ lookback_hours_72_ impression_threshold_400_ share_of_voice_ratio_4.0_ upper_bound_0.95_ alpha_prior_0.1_ beta_prior_20.0_') and filter('k8ns', 'api'), rollup='average').mean(by=['model_name']).mean(over='5m') / 3600
		detect(when(signal >= 4)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average >= 4 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
