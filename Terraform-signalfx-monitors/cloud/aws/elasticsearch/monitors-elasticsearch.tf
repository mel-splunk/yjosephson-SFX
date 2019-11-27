### Elasticsearch cluster status monitor ###
/* Note about the query
    - If aws.es.cluster_statusred is 1 --> query value (= 2.1) > 2 : critical
    - If aws.es.cluster_statusyellow is 1 --> 1 < query value (=1.1) < 2 : warning
    Workaround : in the query, we add "0.1" to the result and we use the comparator ">=". No alert was triggered without that. */
resource "signalfx_detector" "es_cluster_status" {
  count   = var.es_cluster_status_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ElasticSearch cluster status is not green"

/*  query = <<EOQ
  max(${var.es_cluster_status_timeframe}): (
    avg:aws.es.cluster_statusred${module.filter-tags.query_alert} by {region,name} * 2 +
    (avg:aws.es.cluster_statusyellow${module.filter-tags.query_alert} by {region,name} + 0.1)
  ) >= 2
EOQ*/

program_text = <<-EOF
      A = data('elasticsearch.cluster.status', filter=filter('value','2').mean(by=['region','name'])
			B = data('elasticsearch.cluster.status', filter=filter('value','1').mean(by=['region','name'])
		  signal = (A * 2 + (B + 0.1))
			detect(when(signal > ${var.es_cluster_status_threshold_warning}, max('${var.es_cluster_status_timeframe}'))).publish('WARN')
			detect(when(signal > ${var.es_cluster_status_threshold_critical}, max('${var.es_cluster_status_timeframe}'))).publish('CRIT')

EOF

rule {
		description = coalesce(var.es_cluster_status_message, var.message)
		severity = "Warning"
	}

	rule {
		description = coalesce(var.es_cluster_status_message, var.message)
		severity = "Critical"
	}

}

### Elasticsearch cluster free storage space monitor ###
resource "signalfx_detector" "es_free_space_low" {
  count   = var.diskspace_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ElasticSearch cluster free storage space {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

/*  query = <<EOQ
  ${var.diskspace_time_aggregator}(${var.diskspace_timeframe}): (
    avg:aws.es.free_storage_space${module.filter-tags.query_alert} by {region,name} /
    (${var.es_cluster_volume_size}*1000) * 100
  ) < ${var.diskspace_threshold_critical}
EOQ*/

program_text = <<-EOF
      A = data('XXXXX', filter=filter('value','2').${var.diskspace_time_aggregator}().mean(by=['region','name'])
			signal = A / (${var.es_cluster_volume_size}*1000) * 100
      
			detect(when(signal > ${var.diskspace_threshold_warning}, max('${var.diskspace_timeframe}'))).publish('WARN')
			detect(when(signal > ${var.diskspace_threshold_critical}, max('${var.diskspace_timeframe}'))).publish('CRIT')

EOF

rule {
		description = coalesce(var.diskspace_message, var.message)
		severity = "Warning"
	}

	rule {
		description = coalesce(var.diskspace_message, var.message)
		severity = "Critical"
	}

}

### Elasticsearch cluster CPU monitor ###
resource "signalfx_detector" "es_cpu_90_15min" {
  count   = var.cpu_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] ElasticSearch cluster CPU high {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"

/*  query = <<EOQ
  ${var.cpu_time_aggregator}(${var.cpu_timeframe}): (
    avg:aws.es.cpuutilization${module.filter-tags.query_alert} by {region,name}
  ) > ${var.cpu_threshold_critical}
EOQ*/

program_text = <<-EOF
      signal = data('elasticsearch.process.cpu.percent'.${var.cpu_time_aggregator}().mean(by=['region','name'])
			
			detect(when(signal > ${var.cpu_threshold_warning}, max('${var.cpu_timeframe}'))).publish('WARN')
			detect(when(signal > ${var.cpu_threshold_critical}, max('${var.cpu_timeframe}'))).publish('CRIT')

EOF

rule {
		description = coalesce(var.cpu_message, var.message)
		severity = "Warning"
	}

	rule {
		description = coalesce(var.cpu_message, var.message)
		severity = "Critical"
	}

}
