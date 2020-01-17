resource "signalfx_detector" "datalakestore_status" {
	name = "Datalake Store is down"

	program_text = <<-EOF
		signal = data('Status', filter=filter('resource_type', 'Microsoft.DataLakeStore/accounts')).mean(by=['resource_group_id', 'region', 'name']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Max < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
