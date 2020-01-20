resource "signalfx_detector" "keyvault_status" {
	name = "Key Vault is down"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.KeyVault/vaults')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "keyvault_api_result" {
	name = "Key Vault API result rate is low"

	program_text = <<-EOF
		A = data('ServiceApiResult', filter=filter('resource_type', 'Microsoft.KeyVault/vaults') and filter('statuscode', '200'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		B = data('ServiceApiResult', filter=filter('resource_type', 'Microsoft.KeyVault/vaults'), rollup='rate').mean(by=['resource_group_id', 'region', 'name'])
		signal = ((A/B)*100).max(over='5m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Max < 10 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

resource "signalfx_detector" "keyvault_api_latency" {
	name = "Key Vault API latency is high"

	program_text = <<-EOF
		signal = data('ServiceApiLatency', filter=filter('resource_type', 'Microsoft.KeyVault/vaults') and filter('activityname', 'secretlist')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal > 100)).publish('CRIT')
	EOF

	rule {
		description = "Min > 100 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
