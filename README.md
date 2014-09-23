arduinoSpreadsheet
==================

Code sample to upload arduino sensor data to a Google spreadsheet via serial connection to processing.


This set of code is heavily dependent on the Codebox entry posted in 2010 by odewahn. I have update some library dependencies and removed/added some code. The original code can be found here:
http://makezine.com/2010/12/10/save-sensor-data-to-google-spreadsh/

Many thanks to odewahn.


My changes to code grew out of wanting to learn how to get data from my arduino up to a web-accessible location. I do not have a network enabled shield so I was going to use my $500 "shield" - my laptop. I did this in processing because that is what the original post used. I plan on moving this over either into .net or into straight c later on as I am not very comfortable in Java.

Items needed:
- Arduino (or similar)
- Something to measure (I used a temperature sensor)
- USB cable
- processing
- Google Drive account
- Google Drive API
- Guava library
- PC/Mac


Over view:
First set up your arduino to measure something and send the value over serial back to the PC/Mac. I am writing this from a PC user point of view as I do not have a Mac. In theory the general process should be identical.

Write your data value back to the PC:
```
Serial.println(theValue);
```

In processing we need to set up some additional libraries. I am using the latest release values as of this writing. These are used to extend Processing to access the Google Drive API. 

- First up we need Processing. I am using the Windows x64 release versions 2.2.1. (http://www.processing.org/)
- Next we need the gdata-java-client. I am using version 1.47.1. Extract to an appropriate location. (http://code.google.com/p/gdata-java-client/)
- Next is Guava. I am using version 18. Extract to an appropriate location. (https://code.google.com/p/guava-libraries/)

Fire up Processing and create a new sketch (or load XXXXX). You will then need to include the 2 libraries downloaded above. To do this in Processing go to Sketch → Add File. Go to the locations where you extracted the libraries and include the following (this needs to be done one at a time):
\java\lib\gdata-core-1.0.jar
\java\lib\gdata-spreadsheet-3.0.jar
\java\lib\gdata-client-1.0.jar
guava-18.0.jar

The next step is to set up a spreadsheet to write your data into. Go to your Google Docs account and create a new spreadsheet. I called mine “sensor_log”. In the first row create two columns with the headers:

time|temp
----|------

Dont be concerned about data types of the values that will go in here. 

In the processing code you are going to access your spreadsheet with user/pass and the spreadsheet name. It would be better to use OAuth but for now this “just works”. You are then going to write values to the spreadsheet using the Google API call:

```newEntry.getCustomElements().setValueLocal("temp", val);```

If all goes according to plan you should see the new values being added to your spreadsheet.


For an additional coding target I used highstock to plot the values out in a jsFiddle using a public spreadsheet. I am storing my timestamp in milliseconds since the UNIX epoch. The code to read and parse the spreadsheet is very simple:

```javascript
Highcharts.setOptions({
    global: {
        useUTC: false
    }
});

$('#container').highcharts('StockChart', {
    data: {
        googleSpreadsheetKey: '<your spreadsheet key>'
    },
    xAxis: {
        type: 'datetime'
    },
    yAxis: {
        min: 70,
        max: 80,
        plotLines: [{ 
                color: 'red',
                width: 2,
                value: 77,
                dashStyle: 'longdashdot'
            }]
    },
    title: {
        text: 'Temperature (°F)'
    },
    tooltip: {
        xDateFormat: '%Y-%m-%d %l:%M %P',
        valueSuffix: ' °F'
    },
});
```


To Do Items:
- Create .NET serial client
- Create C serial client

