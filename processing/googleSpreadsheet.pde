import processing.net.*;
import processing.serial.*;

import com.google.gdata.client.spreadsheet.*;
import com.google.gdata.data.*;
import com.google.gdata.data.spreadsheet.*;
import com.google.gdata.util.*;

import java.io.IOException;
import java.net.*;
import java.util.*;
import java.util.Calendar;
import java.lang.System.*;

// Variables structures for google spreadsheet API
SpreadsheetService service;  //Holds link to all your spreadsheets
WorksheetEntry worksheet;  //Holds link to the sensor log spreadsheet
String uname = "your user name";  //Your google account user name
String pwd = "your password";  //Your google account password
String spreadsheet_name = "sensor_log";  //Name of the spreadsheet you want to write data to.  Must match exactly, including case.
int spreadsheet_idx = 0; //Index for the "sensor log spreadsheet


//Variables for writing sensor data
Serial port;  // Create object from Serial class
int oldTime;  //timer variable
int reportingInterval = 5000;  //Number of miliiseconds between when sensor data is recorded

// Sends the data to the spreadsheet
void transmitData(String val) {
  int year = year();
  int month = month() - 1;
  int day = day();
  int hour = hour();
  int minute = minute();
  int second = second();

  Calendar cal = Calendar.getInstance();
  cal.clear();
  cal.set(year, month, day, hour, minute, second);

  //Convert time to JS compatible timestamp for use in highcharts.
  String dateVal = Long.toString(cal.getTimeInMillis());
  
  try {
    //Create a new row with the name value pairs
    ListEntry newEntry = new ListEntry();
    newEntry.getCustomElements().setValueLocal("time", dateVal);
    newEntry.getCustomElements().setValueLocal("temp", val);
    
    //Write it out to the google doc
    URL listFeedUrl = worksheet.getListFeedUrl();
    ListEntry insertedRow = service.insert(listFeedUrl, newEntry);
  } 
  catch (Exception e) {
    println(e.getStackTrace());
  }
}


void setup() {
  //Set up the serial port to read data
  //This code comes from example 11-8 of Getting Started with Processing
  String arduinoPort = Serial.list()[0];
  port = new Serial(this, arduinoPort, 9600); //Must match what arduiono code is sending on
  port.bufferUntil('\n');
  oldTime = millis();
  //Set up the google spreadsheet
  service = new SpreadsheetService("test");
  try {
    service.setUserCredentials(uname, pwd);
    URL SPREADSHEET_FEED_URL = new URL(
    "https://spreadsheets.google.com/feeds/spreadsheets/private/full");

    // Make a request to the API and get all spreadsheets.
    SpreadsheetFeed feed = service.getFeed(SPREADSHEET_FEED_URL, SpreadsheetFeed.class);
    List<SpreadsheetEntry> spreadsheets = feed.getEntries();
    //    for (SpreadsheetEntry spreadsheet : spreadsheets) {
    //      // Print the title of this spreadsheet to the screen
    //      System.out.println(spreadsheet.getTitle().getPlainText());
    //    }
    //Fetch the correct spreadsheet
    SpreadsheetEntry se = feed.getEntries().get(spreadsheet_idx); //Fetch the spreadsheet we want
    worksheet = se.getWorksheets().get(0);  //Fetch the first worksheet from that spreadsheet
    //println("Found worksheet " + se.getTitle().getPlainText());
  } 
  catch (Exception e) {
    println(e.toString());
  }
}

//Reads the port every few seconds and sends the data back to Google
void draw() {
  \\Only read up to termintor of line.
  String inString = port.readStringUntil('\n');
  if (inString != null) {
    \\If this has data then check to see if we are still within the set interval.
    \\I have both my arduiono and the processing sketch on the same 300k milisecond (10 minute) interval.
    \\You can set yours to whatever you want. For now it is at every 5 seconds (5000).
    if ((millis() - oldTime) > reportingInterval) {
      oldTime = millis();
      transmitData(inString);
    } 
    //println(inString);
    //transmitData(inString);
  }
}
