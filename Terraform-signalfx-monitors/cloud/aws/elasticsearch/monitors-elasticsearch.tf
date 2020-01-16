### Elasticsearch cluster status monitor ###
resource "signalfx_detector" "es_cluster_status" {
	name = "ElasticSearch cluster status is not green"

	program_text = <<-EOF
		signal = data('gauge.cluster.unassigned-shards', filter=filter('plugin', 'elasticsearch')).mean(by=['aws_region']).max(over='30m')
		detect(when(signal >= 2)).publish('CRIT')
	EOF

	rule {
		description = "Max >= 2 for last 30m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

### Elasticsearch cluster free storage space monitor ###
resource "signalfx_detector" "es_free_space_low" {
	name = "ElasticSearch cluster free storage space"

	/*program_text = <<-EOF
		A = data('XXXXX', filter=filter('plugin', 'elasticsearch')).mean(by=['aws_region'])
		signal = (A / (${var.es_cluster_volume_size}*1000) * 100).max(over='15m')
		detect(when(signal < 10)).publish('CRIT')
	EOF

	rule {
		description = "Max < 10 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}*/

}

### Elasticsearch cluster CPU monitor ###
resource "signalfx_detector" "es_cpu_90_15min" {
	name = "ElasticSearch cluster CPU high"

	program_text = <<-EOF
		signal = data('gauge.process.cpu.percent', filter=filter('plugin', 'elasticsearch')).mean(by=['aws_region']).min(over='15m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Min > 90 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
