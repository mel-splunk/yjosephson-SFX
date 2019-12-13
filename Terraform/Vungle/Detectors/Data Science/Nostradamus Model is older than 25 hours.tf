# Nostradamus Model is older than 25 hours
resource "signalfx_detector" "nostradamus_model_is_older_than_25_hours" {
	name = "Nostradamus Model is older than 25 hours"
	description = "Nostradamus Model is older than 25 hours"

	program_text = <<-EOF
		signal = data('nostradamus.api_server.model_age', filter=filter('deployment', 'prod') and filter('k8ns', 'api') and (not filter('model_name', 'nostradamus.ad_recommenders.common.simple_models.CVStatsByPublisherTask_lookback_5_')) and (not filter('model_name', 'nostradamus.ad_recommenders.common.cpa_optimizer_whalepooling.builder.BuildUserValueModels_dampen_factor_0.5_ whale_percentile_threshold_0.95_')) and (not filter('model_name', 'app_genres_cleaned')), rollup='average').mean(by=['model_name']).mean(over='1h') / 3600
		detect(when(signal >= 25)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average >= 25 for last 1h"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
