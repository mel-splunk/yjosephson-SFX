### Kinesis Firehose Incoming records ###
resource "signalfx_detector" "firehose_incoming_records" {
	name = "Kinesis Firehose No incoming records"

	program_text = <<-EOF
		signal = data('IncomingRecords', filter=filter('namespace', 'AWS/Kinesis')).mean(by=['aws_region','StreamName']).sum(over='15m')
		detect(when(signal <= 0)).publish('CRIT')
	EOF

	rule {
		description = "Sum <= 0 for last 15m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
