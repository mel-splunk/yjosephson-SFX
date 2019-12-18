# SLO Kourier WIN Valid Responses - GKE
resource "signalfx_detector" "slo_kourier_win_valid_responses_gke" {
	name = "SLO Kourier WIN Valid Responses - GKE"
	description = "Kourier WIN SLO is not being met"

	program_text = <<-EOF
		A = data('https/request_count', filter=filter('service', 'loadbalancing') and filter('response_code_class', '200') and filter('matched_url_path_rule', '/v1/win'), rollup='rate').sum()
		B = data('https/request_count', filter=filter('service', 'loadbalancing') and filter('response_code_class', '300') and filter('matched_url_path_rule', '/v1/win'), rollup='rate').sum()
		C = data('https/request_count', filter=filter('service', 'loadbalancing') and filter('response_code_class', '400') and filter('matched_url_path_rule', '/v1/win'), rollup='rate').sum()
		D = data('https/request_count', filter=filter('service', 'loadbalancing') and filter('response_code_class', '500') and filter('matched_url_path_rule', '/v1/win'), rollup='rate').sum()
		E = data('https/request_count', filter=filter('service', 'loadbalancing') and filter('response_code_class', '100') and filter('matched_url_path_rule', '/v1/win'), rollup='rate').sum()
		signal = (A/(A+B+C+D+E)).scale(100).max(over='10m')
		detect(when(signal < 99.5)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Max < 99.5 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
