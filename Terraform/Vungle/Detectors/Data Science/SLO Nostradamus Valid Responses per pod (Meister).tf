# SLO Nostradamus Valid Responses per pod (Meister)
resource "signalfx_detector" "slo_nostradamus_valid_responses_per_pod_meister" {
	name = "SLO Nostradamus Valid Responses per pod (Meister)"
	description = "Nostradamus SLO is not being met"

	program_text = <<-EOF
		A = data('dsp.meister.datasci.request.succeed', filter=filter('environment', 'api-gke'), rollup='rate').sum(by=['host'])
		B = data('dsp.meister.datasci.request.error.http_request_connection', filter=filter('environment', 'api-gke'), rollup='rate').sum(by=['host'])
		C = data('dsp.meister.datasci.request.timeout', filter=filter('environment', 'api-gke'), rollup='rate').sum(by=['host'])
		D = data('dsp.meister.datasci.response.not_status_ok', filter=filter('environment', 'api-gke'), rollup='rate').sum(by=['host'])
		signal = (A/(B + C + D + A)).mean(over='10m').scale(100)
		detect(when(signal < 98)).publish('CRIT')
	EOF

	teams = var.team_id

	rule {
		description = "Average < 98 for last 10m"
		severity = "Critical"
		detect_label = "CRIT"
		notifications = ["Email,foo-alerts@bar.com"]
	}

}
