import codeanticode.syphon.*;
import processing.serial.*;
Serial port;

float maxBright = .875;

int rows = 80;
int columns = 48;
int dataChunkSize = 3;

int prevMag = 3;
boolean flipIt = true; // set this to false to flip the image vertically

byte[] vals = new byte[rows * columns * dataChunkSize];
int rowSize, columnSize;

PGraphics canvas;
PImage img;
SyphonClient client;

public void setup() {
  //String[] syphonConnectionName = new String[3]; 
  //syphonConnectionName[0] = "Serato Video version ";
  //syphonConnectionName[1] = loadStrings("/Users/bryanmartinez/Desktop/videoWallData/versionData.txt")[0];
  //syphonConnectionName[2] = loadStrings("/Users/bryanmartinez/Desktop/videoWallData/versionData.txt")[1];
  
  //String syphonConnectionNameFlattened = join(syphonConnectionName, "");
  String syphonConnectionNameFlattened = "videoStream";
  println(syphonConnectionNameFlattened);
  
  //size(rows*prevMag, columns*prevMag, P3D);
  
  rowSize = width/rows;
  columnSize = height/columns;
  //println(Serial.list());
  
  println("--------------------------");
  println("Available Serial Ports:");
  println(Serial.list());
  String portName = "SomePortName"; // SET SERIAL PORT ASSIGNMENT HERE
  //println("--------------------------");
  port = new Serial(this, portName, 115200); //115200
  //println("Available Syphon servers:");
  //println(SyphonClient.listServers());
  //println("--------------------------");
  //client = new SyphonClient(this, syphonConnectionNameFlattened);
  client = new SyphonClient(this);
  //client = new SyphonClient(this, "Simple Server");
  delay(2000);
}

void draw() {
  if (client.newFrame()) {
    img = client.getImage(img);
    if (img != null) {
      image(img, 0, 0, width, height);  
    }
    loadPixels();
    
    int pixelCounter = 0;
    for (int x = 0; x < rows; x++) {
      if(flipIt == false){
        for (int y = 0; y < columns; y++) {
          int x_loc = x*rowSize + rowSize/2;
          int y_loc = y*columnSize + columnSize/2;
          int loc = x_loc + y_loc*width;
          
          color c = pixels[loc];
          int r = (int) (((c >> 16) & 0xFF) * maxBright);
          int g = (int) (((c >> 8) & 0xFF) * maxBright);
          int b = (int) ((c & 0xFF) * maxBright);
          
          vals[pixelCounter*dataChunkSize] = (byte) r;
          vals[pixelCounter*dataChunkSize+1] = (byte) g;
          vals[pixelCounter*dataChunkSize+2] = (byte) b;
          pixelCounter += 1;
        }
        flipIt = true;
      }
      else{
          for (int y = columns-1; y >= 0; y--) {
            int x_loc = x*rowSize + rowSize/2;
            int y_loc = y*columnSize + columnSize/2;
            int loc = x_loc + y_loc*width;
            
            color c = pixels[loc];
            int r = (int) (((c >> 16) & 0xFF) * maxBright);
            int g = (int) (((c >> 8) & 0xFF) * maxBright);
            int b = (int) ((c & 0xFF) * maxBright);
            
            vals[pixelCounter*dataChunkSize] = (byte) r;
            vals[pixelCounter*dataChunkSize+1] = (byte) g;
            vals[pixelCounter*dataChunkSize+2] = (byte) b;
            pixelCounter += 1;
          }
          flipIt = false;
        }        
      }
    port.write(vals);
}
}