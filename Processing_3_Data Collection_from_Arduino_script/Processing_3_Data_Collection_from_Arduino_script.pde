/* 
  Saving values from Arduino to a .csv File Using Processing - Pseduocode
 
  This sketch provides a basic framework to read data from Arduino over the serial port and save it to .csv file on your computer.
  The .csv file will be saved in the same folder as your Processing sketch.
  This sketch takes advantage of Processing 2.0's built-in Table class.
  This sketch assumes that values read by Arduino are separated by commas, and each Arduino reading is separated by a newline character.
  Each reading will have it's own row and timestamp in the resulting csv file. This sketch will write a new file a set number of times. Each file will contain all records from the beginning of the sketch's run.  
  This sketch pseduo-code only. Comments will direct you to places where you should customize the code.
  This is a beginning level sketch.
 
  The hardware:
  * Sensors connected to Arduino input pins
  * Arduino connected to computer via USB cord
        
  The software:
  *Arduino programmer
  *Processing (download the Processing software here: https://www.processing.org/download/
  *Download the Software Serial library from here: http://arduino.cc/en/Reference/softwareSerial
 
  Created 12 November 2014
  By Elaine Laguerta
  http://url/of/online/tutorial.cc
 
*/
 
import processing.serial.*;
Serial myPort; //creates a software serial port on which you will listen to Arduino
Table dataTable; //table where we will read in and store values. You can name it something more creative!
 
int numReadings = 500; //keeps track of how many readings you'd like to take before writing the file. 
int readingCounter = 0; //counts each reading to compare to numReadings.  
 
String fileName = str(day()) + "-" + str(month()) + "-" + str(year()) + ".csv";
String val;
void setup()
{
   String portName = Serial.list()[0]; 
  //CAUTION: your Arduino port number is probably different! Mine happened to be 1. Use a "handshake" sketch to figure out and test which port number your Arduino is talking on. A "handshake" establishes that Arduino and Processing are listening/talking on the same port.
  //Here's a link to a basic handshake tutorial: https://processing.org/tutorials/overview/
  
  myPort = new Serial(this, portName, 9600); //s
  println(portName);
  dataTable = new Table();
  
  //CAUTION: your Arduino port number is probably different! Mine happened to be 1. Use a "handshake" sketch to figure out and test which port number your Arduino is talking on. A "handshake" establishes that Arduino and Processing are listening/talking on the same port.
  //Here's a link to a basic handshake tutorial: https://processing.org/tutorials/overview/
  
   
  //the following adds columns for time. You can also add milliseconds. See the Time/Date functions for Processing: https://www.processing.org/reference/ 
  dataTable.addColumn("Analog1 Pressure (N)");
  dataTable.addColumn("Analog2 Pressure (N)");
  dataTable.addColumn("Trial Type");
  dataTable.addColumn("Stimuli");
  dataTable.addColumn("Block");
  dataTable.addColumn("Experiment Time Clock (Micro Sec)");
}
 
void serialEvent(Serial myPort)
{
   val = myPort.readStringUntil('\n'); //The newline separator separates each Arduino loop. We will parse the data by each newline separator. 
   if (val!= null)
    { 
      val = trim(val);  //gets rid of any whitespace or Unicode nonbreakable space
      println(val);
      String sensorvals[] = split(val, ';');   //parses the packet from Arduino and places the valeus into the sensorvals array. I am assuming floats. Change the data type to match the datatype coming from Arduino. 
     
      if (float(sensorvals[0]) == -1) 
      {
        saveTable(dataTable, fileName);
        println("Processing programme ended.");
        println("File saved as: " + fileName + ".");
        return;
      }
     
      TableRow newRow = dataTable.addRow();     //add a row for this new reading
      
      //record time stamp
      newRow.setFloat("Analog1 Pressure (N)", float(sensorvals[0]));
      newRow.setFloat("Analog2 Pressure (N)", float(sensorvals[1]));
      newRow.setString("Trial Type", sensorvals[2]);
      newRow.setInt("Stimuli", int(sensorvals[3]));
      newRow.setString("Block", sensorvals[4]);
      newRow.setInt("Experiment Time Clock (Micro Sec)", int(sensorvals[5]));
      
      ++readingCounter; 
      
      if (readingCounter % numReadings == 0){saveTable(dataTable, fileName);}; //saves the table as a csv in the same folder as the sketch every g_numReadings. 
     }
}



void draw()
{
  serialEvent(myPort);
  return;
}
