# Monitoring Azure Search latency
resource "signalfx_detector" "azure_search_latency" {
	name = "Azure Search latency too high"

	program_text = <<-EOF
		signal = data('SearchLatency', filter=filter('resource_type', 'Microsoft.Search/searchServices')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal > 4)).publish('CRIT')
	EOF

	rule {
		description = "Min > 4 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}

# Monitoring Azure Search throttled queries
resource "signalfx_detector" "azure_search_throttled_queries_rate" {
	name = "Azure Search throttled queries rate is too high"

	program_text = <<-EOF
		signal = data('ThrottledSearchQueriesPercentage', filter=filter('resource_type', 'Microsoft.Search/searchServices')).mean(by=['resource_group_id', 'region', 'name']).min(over='5m')
		detect(when(signal > 50)).publish('CRIT')
	EOF

	rule {
		description = "Min > 50 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}
}
