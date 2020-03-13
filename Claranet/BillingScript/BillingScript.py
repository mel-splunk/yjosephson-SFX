# -*- coding: utf-8 -*-

from copy import deepcopy
from datetime import datetime, timedelta
import csv
import signalfx
import json
import argparse
import pandas as pd
import numpy as np

SIGNALFX_API_KEY = 'XXXX'

sfx = signalfx.SignalFx(api_endpoint='https://api.eu0.signalfx.com',
		ingest_endpoint='https://ingest.eu0.signalfx.com',
		stream_endpoint='https://stream.eu0.signalfx.com')


# For the ingest API
ingest = sfx.ingest(SIGNALFX_API_KEY)

# For the REST API
rest = sfx.rest(SIGNALFX_API_KEY)

# For the SignalFlow API
flow = sfx.signalflow(SIGNALFX_API_KEY)



class CustomJSONEncoder(json.JSONEncoder):
	"""Custom JSON encoder that converts datetime objects to ISO 8601 formatted strings."""

	def default(self, obj):
		"""Overrides the default serialization of JSONEncoder then calls the JSONEncoder default() method.

		:param obj: Object to serialize.
		:type obj: object
		:return: json.JSONEncoder.default() object.
		:rtype: instance
		"""
		try:
			if isinstance(obj, (datetime.datetime, datetime.time, datetime.date)):
				return obj.isoformat()
			if isinstance(obj, datetime.timedelta):
				return int(obj.days * 86400 + obj.seconds)
			iterable = iter(obj)
		except TypeError:
			pass
		else:
			return list(iterable)
		return json.JSONEncoder.default(self, obj)


def pretty_json(data, encoder=CustomJSONEncoder):
	"""Takes a dictionary or list and converts it into a pretty-print JSON string.

	:param data: Dictionary or list to be converted.
	:type data: dict or list
	:param encoder: (optional) Custom encoder to supplement complex serializations. (default: CustomJSONEncoder)
	:type encoder: instance
	:return: String of pretty JSON awesomeness.
	:rtype: str
	"""
	if encoder is not None:
		return json.dumps(data, sort_keys=True, indent=4, separators=(',', ': '), encoding='utf8', ensure_ascii=True,
						  cls=encoder)
	return json.dumps(data, sort_keys=True, indent=4, separators=(',', ': '), encoding='utf8', ensure_ascii=True)


def convert_dt_to_milliseconds(dt_obj):
	"""Convert  datetime object to a Unix epoch timestamp in milliseconds.

	:param dt_obj: Datetime object to be converted.
	:type dt_obj: instance
	:return: Milliseconds since the Unix epoch.
	:rtype: int or long
	"""
	return int((dt_obj - datetime(1970, 1, 1)).total_seconds() * 1000)


def get_signalflow_results(program, start, stop, resolution=None, **kwargs):
	"""Use the SignalFlow Python client library to execute SignalFlow programs.

	:param program: Program text to be executed.
	:type program: str or unicode
	:param start: SignalFlow start time in milliseconds.
	:param start: int or long
	:param stop: SignalFlow start time in milliseconds.
	:type stop: int or long
	:param resolution: (optional) Data resolution. (default: None)
	:type resolution: int, long, str, or unicode
	:param kwargs: Miscellaneous keyword arguments to be used in `signalfx.SignalFx.signalflow().execute()`.
	:type kwargs: keyword arguments
	:return: Dictionary of results.
	:rtype: dict
	"""
	metadata = {}
	results = {}
	single_datapoint_results = {}
	metadata = {}

	argz = {
		'program': program,
		'start': start,
		'stop': stop,
		'resolution': resolution
	}

	# Add any additional arguments to the SignalFlow execute() function.
	# https://developers.signalfx.com/docs/signalflow-execute
	argz.update(**kwargs)

	for msg in flow.execute(**argz).stream():
		# Get all values

		if isinstance(msg, signalfx.signalflow.messages.MetadataMessage):
			for k, v in msg.properties.items():
				if ("childOrgName" in k):
					metadata[msg.tsid] = v

		if isinstance(msg, signalfx.signalflow.messages.DataMessage):
			result = {}

			if msg.data.items():
				for tsid, val in msg.data.items():
					result[metadata.get(tsid, {})] = val

				results[msg.logical_timestamp_ms] = deepcopy(result)

	return results

def main():
	print('Executing SignalFlow.')

	parser = argparse.ArgumentParser(description=(
		'SignalFlow'))
	parser.add_argument('-ym', '--yearmonth', type=int, help='yearmonth to compute')
	inputoptions = parser.parse_args()

	# If no month/year passed into the program, then grab the current UTC time and set it as the end time and our start time will be 15 minutes previous!
	if not inputoptions.yearmonth:
		end_time_obj = datetime.utcnow()
		start_time_obj = end_time_obj - timedelta(minutes=15)
	else:
		# For desired month/year, set the end time to 5min into the month and our start time will be stop time minus 10 minutes!
		enddate = datetime.strptime(str(inputoptions.yearmonth), '%Y%m')
		end_time_obj = enddate + timedelta(minutes=5)
		start_time_obj = end_time_obj - timedelta(minutes=10)

	print ('endtime: ', end_time_obj)
	print ('starttime: ', start_time_obj)

	# Now convert them to proper timestamps in milliseconds.
	end = convert_dt_to_milliseconds(end_time_obj)
	start = convert_dt_to_milliseconds(start_time_obj)

	# Each item in this list will represent a SignalFlow program line. We will assemble these later.
	signal_flow_program_parts = [
		"A = data('sf.org.child.numResourcesMonitored', filter=filter('resourceType', 'host')).sum(by=['childOrgName']).mean(cycle='hour', cycle_start='0m', partial_values=False).mean(cycle='month', cycle_start='1d', partial_values=False).publish(label='A')"
	]

	# Assemble each item in the array to a large program text with each item on it's own line.
	assembled_program_text = '\n'.join(signal_flow_program_parts)

	results = get_signalflow_results(program=assembled_program_text, start=start, stop=end, resolution=900000, immediate=True)

	json_parsed = json.dumps(results)

	HostDataFlag = 0
	ContainerDataFlag = 0
	CustomMetricsDataFlag = 0

	#print (len(json_parsed))
	if (len(json_parsed) > 2):
		HostDataFlag = 1
		OutputFileNameH = "Host.csv"
		pd.read_json(json_parsed).to_csv(OutputFileNameH, header=1)

		# add header
		csvfile = pd.read_csv(OutputFileNameH, sep=',')
		Frame = pd.DataFrame(csvfile.values, columns = ["ChildOrgName", "Host"])
		Frame.to_csv(OutputFileNameH, sep=',', index=False)
		
	# Each item in this list will represent a SignalFlow program line. We will assemble these later.
	signal_flow_program_parts = [
		"A = data('sf.org.child.numResourcesMonitored', filter=filter('resourceType', 'container')).sum(by=['childOrgName']).mean(cycle='hour', cycle_start='0m', partial_values=False).mean(cycle='month', cycle_start='1d', partial_values=False).publish(label='A')"
	]

	# Assemble each item in the array to a large program text with each item on it's own line.
	assembled_program_text = '\n'.join(signal_flow_program_parts)

	results = get_signalflow_results(program=assembled_program_text, start=start, stop=end, resolution=900000, immediate=True)

	json_parsed = json.dumps(results)

	if (len(json_parsed) > 2):
		ContainerDataFlag = 1
		OutputFileNameC = "Container.csv"
		pd.read_json(json_parsed).to_csv(OutputFileNameC, header=1)

		# add header
		csvfile = pd.read_csv(OutputFileNameC, sep=',')
		Frame = pd.DataFrame(csvfile.values, columns = ["ChildOrgName", "Container"])
		Frame.to_csv(OutputFileNameC, sep=',', index=False)

	# Each item in this list will represent a SignalFlow program line. We will assemble these later.
	signal_flow_program_parts = [
		"A = data('sf.org.child.numCustomMetrics').sum(by=['childOrgName']).mean(cycle='hour', cycle_start='0m', partial_values=False).mean(cycle='month', cycle_start='1d', partial_values=False).publish('A')"
	]

	# Assemble each item in the array to a large program text with each item on it's own line.
	assembled_program_text = '\n'.join(signal_flow_program_parts)

	results = get_signalflow_results(program=assembled_program_text, start=start, stop=end, resolution=900000, immediate=True)

	json_parsed = json.dumps(results)

	if (len(json_parsed) > 2):
		CustomMetricsDataFlag = 1
		OutputFileNameM = "CustomMetrics.csv"
		pd.read_json(json_parsed).to_csv(OutputFileNameM, header=1)

		# add header
		csvfile = pd.read_csv(OutputFileNameM, sep=',')
		Frame = pd.DataFrame(csvfile.values, columns = ["ChildOrgName", "CustomMetrics"])
		Frame.to_csv(OutputFileNameM, sep=',', index=False)

	# Combine all files
	OutputFileMerge1 = 'MergedFile1.csv'
	OutputFileMerge2 = 'MergedFile2.csv'
	OutputFileNameFinal = "BillingOutput.csv"

	if HostDataFlag == 1 and ContainerDataFlag == 1 and CustomMetricsDataFlag == 1:
		dfsH = pd.read_csv(OutputFileNameH)
		dfsC = pd.read_csv(OutputFileNameC)
		merged1 = pd.merge(dfsH, dfsC, on='ChildOrgName', how='outer')
		merged1.to_csv(OutputFileMerge1, index=False)

		dfsM = pd.read_csv(OutputFileNameM)
		dfs1 = pd.read_csv(OutputFileMerge1)
		merged2 = pd.merge(dfs1, dfsM, on='ChildOrgName', how='outer')
		merged2.to_csv(OutputFileMerge2, index=False)

		# Add License calculation
		# Compare Host count to (Container/20) to (CustomMetrics/200) return largest value
		df = pd.read_csv(OutputFileMerge2, header=0, sep=',')
		df1 = df

		df1['Host1'] = df.apply(lambda x: x['Host'] if x['Host'] is not np.nan else 0, axis = 1)
		df1['Container1'] = (df.apply(lambda y: y['Container'] if y['Container'] is not np.nan else 0, axis = 1)/20)
		df1['CustomMetrics1'] = (df.apply(lambda z: z['CustomMetrics'] if z['CustomMetrics'] is not np.nan else 0, axis = 1)/200)

		df['Licenses'] = df1[['Host1','Container1','CustomMetrics1']].max(axis=1, numeric_only=True)

		df = df.drop(['Host1', 'Container1', 'CustomMetrics1'], axis=1)

		columnlist = ['ChildOrgName', 'Host', 'Container', 'CustomMetrics', 'Licenses']
		df.columns = columnlist

		df.to_csv(OutputFileNameFinal, index=False)

	elif HostDataFlag == 1 and ContainerDataFlag == 1 and CustomMetricsDataFlag == 0:
		dfsH = pd.read_csv(OutputFileNameH)
		dfsC = pd.read_csv(OutputFileNameC)
		merged1 = pd.merge(dfsH, dfsC, on='ChildOrgName', how='outer')
		merged1.to_csv(OutputFileMerge1, index=False)

		# Add License calculation
		# Compare Host count to (Container/20) return largest value
		df = pd.read_csv(OutputFileMerge1, header=0, sep=',')
		df1 = df

		df1['Host1'] = df.apply(lambda x: x['Host'] if x['Host'] is not np.nan else 0, axis = 1)
		df1['Container1'] = (df.apply(lambda y: y['Container'] if y['Container'] is not np.nan else 0, axis = 1)/20)

		df['Licenses'] = df1[['Host1','Container1']].max(axis=1, numeric_only=True)

		df = df.drop(['Host1', 'Container1'], axis=1)

		columnlist = ['ChildOrgName', 'Host', 'Container', 'Licenses']
		df.columns = columnlist

		df.to_csv(OutputFileNameFinal, index=False)
	
	elif HostDataFlag == 1 and ContainerDataFlag == 0 and CustomMetricsDataFlag == 1:
		dfsH = pd.read_csv(OutputFileNameH)
		dfsC = pd.read_csv(OutputFileNameM)
		merged1 = pd.merge(dfsH, dfsC, on='ChildOrgName', how='outer')
		merged1.to_csv(OutputFileMerge1, index=False)

		# Add License calculation
		# Compare Host count to (CustomMetrics/200) return largest value
		df = pd.read_csv(OutputFileMerge1, header=0, sep=',')
		df1 = df

		df1['Host1'] = df.apply(lambda x: x['Host'] if x['Host'] is not np.nan else 0, axis = 1)
		df1['CustomMetrics1'] = (df.apply(lambda z: z['CustomMetrics'] if z['CustomMetrics'] is not np.nan else 0, axis = 1)/200)

		df['Licenses'] = df1[['Host1','CustomMetrics1']].max(axis=1, numeric_only=True)

		df = df.drop(['Host1', 'CustomMetrics1'], axis=1)

		columnlist = ['ChildOrgName', 'Host', 'CustomMetrics', 'Licenses']
		df.columns = columnlist

		df.to_csv(OutputFileNameFinal, index=False)

	elif HostDataFlag == 1 and ContainerDataFlag == 0 and CustomMetricsDataFlag == 0:
		# Add License calculation
		# Return only Host count
		df = pd.read_csv(OutputFileNameH, header=0, sep=',')
		df1 = df

		df1['Host1'] = df.apply(lambda x: x['Host'] if x['Host'] is not np.nan else 0, axis = 1)

		df['Licenses'] = df1[['Host1']].max(axis=1, numeric_only=True)

		df = df.drop(['Host1'], axis=1)

		columnlist = ['ChildOrgName', 'Host', 'Licenses']
		df.columns = columnlist

		df.to_csv(OutputFileNameFinal, index=False)

	elif HostDataFlag == 0 and ContainerDataFlag == 1 and CustomMetricsDataFlag == 1:
		dfsH = pd.read_csv(OutputFileNameC)
		dfsC = pd.read_csv(OutputFileNameM)
		merged1 = pd.merge(dfsH, dfsC, on='ChildOrgName', how='outer')
		merged1.to_csv(OutputFileMerge1, index=False)

		# Add License calculation
		# Compare (Container/20) to (CustomMetrics/200) return largest value
		df = pd.read_csv(OutputFileMerge1, header=0, sep=',')
		df1 = df

		df1['Container1'] = (df.apply(lambda y: y['Container'] if y['Container'] is not np.nan else 0, axis = 1)/20)
		df1['CustomMetrics1'] = (df.apply(lambda z: z['CustomMetrics'] if z['CustomMetrics'] is not np.nan else 0, axis = 1)/200)

		df['Licenses'] = df1[['Container1','CustomMetrics1']].max(axis=1, numeric_only=True)

		df = df.drop(['Container1', 'CustomMetrics1'], axis=1)

		columnlist = ['ChildOrgName', 'Container', 'CustomMetrics', 'Licenses']
		df.columns = columnlist

		df.to_csv(OutputFileNameFinal, index=False)

	elif HostDataFlag == 0 and ContainerDataFlag == 0 and CustomMetricsDataFlag == 1:
		# Add License calculation
		# Return only (CustomMetrics/200) count
		df = pd.read_csv(OutputFileM, header=0, sep=',')
		df1 = df

		df1['CustomMetrics1'] = (df.apply(lambda z: z['CustomMetrics'] if z['CustomMetrics'] is not np.nan else 0, axis = 1)/200)

		df['Licenses'] = df1[['CustomMetrics1']].max(axis=1, numeric_only=True)

		df = df.drop(['CustomMetrics1'], axis=1)

		columnlist = ['ChildOrgName', 'CustomMetrics', 'Licenses']
		df.columns = columnlist

		df.to_csv(OutputFileNameFinal, index=False)
	
	elif HostDataFlag == 0 and ContainerDataFlag == 1 and CustomMetricsDataFlag == 0:
		# Add License calculation
		# Return only (Container/20) count
		df = pd.read_csv(OutputFileC, header=0, sep=',')
		df1 = df

		df1['Container1'] = (df.apply(lambda y: y['Container'] if y['Container'] is not np.nan else 0, axis = 1)/20)

		df['Licenses'] = df1[['Container1']].max(axis=1, numeric_only=True)

		df = df.drop(['Container1'], axis=1)

		columnlist = ['ChildOrgName', 'Container', 'Licenses']
		df.columns = columnlist

		df.to_csv(OutputFileNameFinal, index=False)
	else:
		print ('No Metrics Data')

	print('THE END!')


if __name__ == '__main__':
	main()

