resource "signalfx_detector" "storage_status" {
	name = "Azure Storage is down"

	program_text = <<-EOF
		signal = data('storage').mean(by=['azure_region', 'azure_resource_group_name', 'azure_resource_group_region']).max(over='5m')
		detect(when(signal < 1)).publish('CRIT')
	EOF

	rule {
		description = "Maximum < 1 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "blobservices_requests_error" {
	name = "Azure Storage Blob service too few successful requests"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('responsetype', 'Success') and filter('apiname', '*Blob*') and (not filter('apiname', 'GetBlobProperties')) and (not filter('apiname', 'CreateContainer')), rollup='rate', extrapolation='zero').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*') and (not filter('apiname', 'GetBlobProperties')) and (not filter('apiname', 'CreateContainer')), rollup='rate', extrapolation='zero').sum(by=['resource_group_id', 'apiname'])
		signal = (100-(A/B)).scale(100).max(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Maximum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "fileservices_requests_error" {
	name = "Azure Storage File service too few successful requests"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('responsetype', 'Success') and filter('apiname', 'GetFileServiceProperties'), rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties'), rollup='rate').sum(by=['resource_group_id'])
		signal = (100-(A/B)).scale(100).max(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Maximum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "queueservices_requests_error" {
	name = "Azure Storage Queue service too few successful requests"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('responsetype', 'Success') and filter('apiname', 'GetQueueServiceProperties'), rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties'), rollup='rate').sum(by=['resource_group_id'])
		signal = (100-(A/B)).scale(100).max(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Maximum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "tableservices_requests_error" {
	name = "Azure Storage Table service too few successful requests"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('responsetype', 'Success') and filter('apiname', '*Table*'), rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*'), rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (100-(A/B)).scale(100).max(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Maximum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "blobservices_latency" {
	name = "Azure Storage Blob service too high end to end latency"

	program_text = <<-EOF
		signal = data('SuccessE2ELatency', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*'), extrapolation='zero').mean(by=['resource_group_id', 'apiname']).min(over='5m')
		detect(when(signal > 2000)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 2000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "fileservices_latency" {
	name = "Azure Storage File service too high end to end latency"

	program_text = <<-EOF
		signal = data('SuccessE2ELatency', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties'), extrapolation='zero').mean(by=['resource_group_id']).min(over='5m')
		detect(when(signal > 2000)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 2000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "queueservices_latency" {
	name = "Azure Storage Queue service too high end to end latency"

	program_text = <<-EOF
		signal = data('SuccessE2ELatency', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties'), extrapolation='zero').mean(by=['resource_group_id']).min(over='5m')
		detect(when(signal > 2000)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 2000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "tableservices_latency" {
	name = "Azure Storage Table service too high end to end latency"

	program_text = <<-EOF
		signal = data('SuccessE2ELatency', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*'), extrapolation='zero').mean(by=['resource_group_id', 'apiname']).min(over='5m')
		detect(when(signal > 2000)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 2000 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "blob_timeout_error_requests" {
	name = "Azure Blob Storage too many timeout errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*') and filter('responsetype', 'ServerTimeoutError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "file_timeout_error_requests" {
	name = "Azure File Storage too many timeout errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties') and filter('responsetype', 'ServerTimeoutError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "queue_timeout_error_requests" {
	name = "Azure Queue Storage too many timeout errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties') and filter('responsetype', 'ServerTimeoutError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "table_timeout_error_requests" {
	name = "Azure Table Storage too many timeout errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*') and filter('responsetype', 'ServerTimeoutError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "blob_network_error_requests" {
	name = "Azure Blob Storage too many network errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*') and filter('responsetype', 'NetworkError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "file_network_error_requests" {
	name = "Azure File Storage too many network errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties') and filter('responsetype', 'NetworkError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "queue_network_error_requests" {
	name = "Azure Queue Storage too many network errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties') and filter('responsetype', 'NetworkError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "table_network_error_requests" {
	name = "Azure Table Storage too many network errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*') and filter('responsetype', 'NetworkError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "blob_throttling_error_requests" {
	name = "Azure Blob Storage too many throttling errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*') and filter('responsetype', 'ServerBusyError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "file_throttling_error_requests" {
	name = "Azure File Storage too many throttling errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties') and filter('responsetype', 'ServerBusyError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "queue_throttling_error_requests" {
	name = "Azure Queue Storage too many throttling errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties') and filter('responsetype', 'ServerBusyError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "table_throttling_error_requests" {
	name = "Azure Table Storage too many throttling errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*') and filter('responsetype', 'ServerBusyError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "blob_server_other_error_requests" {
	name = "Azure Blob Storage too many server_other errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*') and filter('responsetype', 'ServerOtherError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "file_server_other_error_requests" {
	name = "Azure File Storage too many server_other errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties') and filter('responsetype', 'ServerOtherError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "queue_server_other_error_requests" {
	name = "Azure Queue Storage too many server_other errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties') and filter('responsetype', 'ServerOtherError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "table_server_other_error_requests" {
	name = "Azure Table Storage too many server_other errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*') and filter('responsetype', 'ServerOtherError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "blob_client_other_error_requests" {
	name = "Azure Blob Storage too many client_other errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*') and filter('responsetype', 'ClientOtherError') and (not filter('apiname', 'GetBlobProperties')) and (not filter('apiname', 'CreateContainer')), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*') and (not filter('apiname', 'GetBlobProperties')) and (not filter('apiname', 'CreateContainer')), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "file_client_other_error_requests" {
	name = "Azure File Storage too many client_other errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties') and filter('responsetype', 'ClientOtherError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "queue_client_other_error_requests" {
	name = "Azure Queue Storage too many client_other errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties') and filter('responsetype', 'ClientOtherError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "table_client_other_error_requests" {
	name = "Azure Table Storage too many client_other errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*') and filter('responsetype', 'ClientOtherError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "blob_authorization_error_requests" {
	name = "Azure Blob Storage too many authorization errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*') and filter('responsetype', 'AuthorizationError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Blob*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "file_authorization_error_requests" {
	name = "Azure File Storage too many authorization errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties') and filter('responsetype', 'AuthorizationError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetFileServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "queue_authorization_error_requests" {
	name = "Azure Queue Storage too many authorization errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties') and filter('responsetype', 'AuthorizationError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', 'GetQueueServiceProperties'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}

resource "signalfx_detector" "table_authorization_error_requests" {
	name = "Azure Table Storage too many authorization errors"

	program_text = <<-EOF
		A = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*') and filter('responsetype', 'AuthorizationError'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		B = data('Transactions', filter=filter('resource_type', 'Microsoft.Storage/storageAccounts') and filter('apiname', '*Table*'), extrapolation='zero', rollup='rate').sum(by=['resource_group_id', 'apiname'])
		signal = (A/B).scale(100).min(over='5m')
		detect(when(signal > 90)).publish('CRIT')
	EOF

	rule {
		description = "Minimum > 90 for last 5m"
		severity = "Critical"
		detect_label = "CRIT"
	}

}
