### Kinesis Firehose Incoming records ###
resource "signalfx_monitor" "firehose_incoming_records" {
  count   = var.incoming_records_enabled == "true" ? 1 : 0
  name    = "${var.prefix_slug == "" ? "" : "[${var.prefix_slug}]"}[${var.environment}] Kinesis Firehose No incoming records"

  /*query = <<EOQ
    sum(${var.incoming_records_timeframe}): (
      avg:aws.firehose.incoming_records${module.filter-tags.query_alert} by {region,deliverystreamname}
    ) <= 0
  EOQ*/

  program_text = <<-EOF
      signal = data('IncomingRecords', filter=filter('namespace', 'AWS/Firehose'), rollup='mean').mean(by=['aws_region','DeliveryStreamName'])
			
			detect(when(signal <= 0, ${var.incoming_records_timeframe})).publish('CRIT')

  EOF

	rule {
		description = coalesce(var.incoming_records_message, var.message)
		severity = "Critical"
	}

}
