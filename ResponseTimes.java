package com.signalfx_yo_test;


import com.codahale.metrics.*;
import java.util.concurrent.TimeUnit;

import com.signalfx.codahale.reporter.*;
import com.signalfx.metrics.auth.StaticAuthToken;
import com.signalfx.endpoint.*;
import java.io.*;



import java.util.Arrays;
import java.lang.*;
//import java.net.URL;
//import java.net.MalformedURLException;

public class ResponseTimes 
{




    public static void main( String[] args ) {
	final MetricRegistry metricRegistry = new MetricRegistry();

	
	final String ingestStr = "ingest.us1.signalfx.com";
	//try{
	//	URL ingestUrl = new URL(ingestStr);
	//}catch(MalformedURLException ex){
		//do exception handling here
	//}
	SignalFxReceiverEndpoint endpoint = new SignalFxEndpoint("https",
    		ingestStr, 443);

	//SignalFxReporter signalfxReporter = new SignalFxReporter.Builder(metricRegistry,
    	//	new StaticAuthToken("OdlNmgCPBou9EjLqikdGDg"), ingestStr).setEndpoint(endpoint);

	SignalFxReporter signalfxReporter = new SignalFxReporter.Builder(metricRegistry,
    		new StaticAuthToken("OdlNmgCPBou9EjLqikdGDg"), ingestStr)
	.setEndpoint(endpoint)
	.build();
        signalfxReporter.start(1, TimeUnit.SECONDS);

        final MetricMetadata metricMetadata = signalfxReporter.getMetricMetadata();



        int i = 0;


        String[] sites = {"google.com", "duckduckgo.com", "bing.com", "weather.com", "nasdaq.com", "finance.yahoo.com"};

        int sitesindex = 0;



        while (i == 0) {


            if (sitesindex > 5) {

                sitesindex = 0;

		//break;
            }


            String stringURL = "http://" + sites[sitesindex];



            long starttime = System.currentTimeMillis();



            String url = sites[sitesindex];

            String[] command = {"C:\\Users\\ybjos\\OneDrive\\Desktop\\curl-7.65.3-win64-mingw\\curl-7.65.3-win64-mingw\\bin\\curl", "-u", "Accept:application/json", url};

	    System.out.println("command " + Arrays.toString(command));
            ProcessBuilder process = new ProcessBuilder(command);

            System.out.println("URL " + url);


            try {

                Process p = process.start();


		InputStream response = p.getInputStream();
		InputStreamReader isr = new InputStreamReader(response);
		BufferedReader br = new BufferedReader(isr);
		StringBuilder responseStrBuilder = new StringBuilder();

		String line = new String();

		while ((line = br.readLine()) != null) {
    			System.out.println("read line from curl command: " + line);
    			responseStrBuilder.append(line);
		}
            } catch (IOException e) {

                System.out.print("error");

                e.printStackTrace();

            }

	
            long endtime = System.currentTimeMillis();


            final long resulttime = endtime - starttime;




	    System.out.println("resulttime: " + resulttime);
	    try{
            	metricMetadata.forMetric(new Gauge<Long>() {


                	@Override

                	public Long getValue() {

                    		return resulttime;

                	}


            	}).withMetricName("yo_http_response_timeJava").withDimension("yo_site", sites[sitesindex])
.register(metricRegistry);

	    } catch (IllegalArgumentException e) {
		SharedMetricRegistries.clear();
    	    }

	    signalfxReporter.report();
            sitesindex += 1;


            try {

                TimeUnit.SECONDS.sleep(3);

            } catch (InterruptedException e) {

                e.printStackTrace();

            }

        }

    }

}



