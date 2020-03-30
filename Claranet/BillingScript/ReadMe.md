# Billing script

This python sdk run signalflow for Container, Host, and Custom Metrics and return output csv file

## Input parameter:
-ym or --yearmonth (yearmonth to compute, example: 200210 or 20022)

This will set the end time to 5 minutes into the month and start time will be the stop time minus 10 minutes.	

By default if this parameter did not get passed in, it will use the current UTC time and set it as the end time and start time will be 15 minutes prior.


## How to run the program:

python BillingScript.py -ym 20202


## Output CSV file format:

Column 1: Host

Column 2: Container

Column 3: Custom Metrics

Column 4: Licenses (Compare Host count to (Container count/20) to (Custom Metrics count/200) returns largest value)
