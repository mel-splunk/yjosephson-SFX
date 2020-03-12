# -*- coding: utf-8 -*-

from copy import deepcopy
from datetime import datetime, timedelta
import csv
import signalfx
import json
import argparse
import pandas

SIGNALFX_API_KEY = '8pTi_Ul7wVR-dC0xGT2aJw'

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
		# For metadata messages, get all values and ignore the Pythonic options that start with a double underscore.
		"""if isinstance(msg, signalfx.signalflow.messages.MetadataMessage):
			md = msg.__dict__
			metadata[md.get('_tsid')] = {k: md[k] for k in md.keys() if not k.startswith('__')}

		if isinstance(msg, signalfx.signalflow.messages.DataMessage):
			# Temporary dictionary to old the results from the `DataMessage`.
			result = {}

			# For each item in the rollup window, add the saved metadata for the metric timeseries along with the value.
			for tsid, val in msg.data.items():
				result[tsid] = metadata.get(tsid, {})
				result[tsid]['@value'] = val

			# Add the results of this temporary dictionary to the master results dictionary. Use deepcopy() to ensure
			# all of the data is copied into the master results dictionary and not just Python adding references which
			# can result in incorrect data.
			results[msg.logical_timestamp_ms] = deepcopy(result)

			# No metadata:
			# results[msg.logical_timestamp_ms] = msg.data
		"""
		if isinstance(msg, signalfx.signalflow.messages.MetadataMessage):
			for k, v in msg.properties.items():
				if ("childOrgName" in k):
					metadata[msg.tsid] = v

		if isinstance(msg, signalfx.signalflow.messages.DataMessage):
			result = {}
			if msg.data.items():
				for tsid, val in msg.data.items():
					#print(tsid, val)
					#print(metadata.get(tsid, {}))
					result[metadata.get(tsid, {})] = val

				results[msg.logical_timestamp_ms] = deepcopy(result)

	return results


def main():
	print('Executing SignalFlow.')

	parser = argparse.ArgumentParser(description=(
		'SignalFlow'))
	parser.add_argument('-ym', '--yearmonth', type=int, help='yearmonth to compute')
	inputoptions = parser.parse_args()

	# Each item in this list will represent a SignalFlow program line. We will assemble these later.
	signal_flow_program_parts = [
		"A = data('sf.org.child.numResourcesMonitored', filter=filter('resourceType', 'container')).sum(by=['childOrgName']).mean(cycle='hour', cycle_start='0m', partial_values=False).mean(cycle='month', cycle_start='1d', partial_values=False).publish(label='A')"
	]

	# Assemble each item in the array to a large program text with each item on it's own line.
	assembled_program_text = '\n'.join(signal_flow_program_parts)

	# If no month/year passed into the program, then grab the current UTC time and set it as the end time and our start time will be 15 minutes previous!
	if not inputoptions.yearmonth:
		end_time_obj = datetime.utcnow()
		start_time_obj = end_time_obj - timedelta(minutes=15)
	else:
		# For desired month/year, set the end time to 5min into the month and our start time will be stop time minus 10 minutes!
		enddate = datetime.strptime(str(inputoptions.yearmonth), '%Y%m')
		end_time_obj = enddate + timedelta(minutes=5)
		start_time_obj = end_time_obj - timedelta(minutes=10)

	#print ('endtime: ', end_time_obj)
	#print ('starttime: ', start_time_obj)

	# Now convert them to proper timestamps in milliseconds.
	end = convert_dt_to_milliseconds(end_time_obj)
	start = convert_dt_to_milliseconds(start_time_obj)

	results = get_signalflow_results(program=assembled_program_text, start=start, stop=end, resolution=900000, immediate=True)

	json_parsed = json.dumps(results)
	#print(json_parsed)

	OutputFileName = "BillingOutput.csv"
	pandas.read_json(json_parsed).to_csv(OutputFileName, header=1)

	# add header
	csvfile = pandas.read_csv(OutputFileName, sep=',')
	Frame = pandas.DataFrame(csvfile.values, columns = ["ChildOrgName", "Container"])
	Frame.to_csv(OutputFileName, sep=',', index=False)

	print('THE END!')


if __name__ == '__main__':
	main()