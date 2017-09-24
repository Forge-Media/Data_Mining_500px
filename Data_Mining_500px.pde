/**
* 500px Mapper
*
* A simple application which maps images from 500px (http://www.500px.com)
* 
* by Jeremy Paton, 2016
* www.jeremypaton.com
*
*/

import controlP5.*;

import java.text.SimpleDateFormat;
import java.util.*;
import java.text.ParseException;

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.Google;
import de.fhpotsdam.unfolding.providers.Microsoft;

ControlP5 cp5;
UnfoldingMap map;
fivehudredAPI fiveapi;

//500px API keys
final String consumerkey = "INSERT-YOUR-CONSUMER-KEY-HERE";
final String consumersecret = "INSERT-YOUR-CONSUMER-SECRET-HERE";
//If 500px API is down set to false
final Boolean useAPI = false;
//Load all pages (true) load first page only (false)
final Boolean multicheck = false;

//Search Parameters
String geolocation = "63.8979257,-22.0360363";
String radius = "40km";
String results = "100";
String exclude = "Celebrities,Concert,Family,Fashion,Food,Macro,Nude,People,Performing%20Arts,Sport,Transportation,Wedding";
float[] list = float(split(geolocation, ','));
Location searchLocation = new Location(list[0], list[1]);

//Initial point size
int pointSize = 10;

//Controller parameters
Boolean showid = false;
Boolean showrating = false;
Boolean showphoto = false;
Boolean search = false;
Boolean filter = false;
String searchValue = "Aurora";

//Night time
int sunset = 2000;
int sunrise = 600;

//Font
PFont f;
PImage temp_img, maskImage;
RadioButton r;

void setup() {

  //Set window size
  size(1440, 900, P2D);
  smooth();
  
  //Generate controlers
  cp5 = new ControlP5(this);

  //Generate a new map
  map = new UnfoldingMap(this, 0, 0, 1440, 825);
  //map = new UnfoldingMap(this, 0, 0, 1440, 825, new Microsoft.AerialProvider());
  //map = new UnfoldingMap(this, 0, 0, 1440, 825, new Google.GoogleTerrainProvider());
  MapUtils.createDefaultEventDispatcher(this, map);

  //Set location & restrictions
  Location icelandLocation = new Location(64.006433f, -21.866943f);
  float maxPanningDistance = 50; // in km
  map.zoomAndPanTo(10, icelandLocation);
  map.setPanningRestriction(icelandLocation, maxPanningDistance);
  map.setZoomRange(10,15);

  SimplePointMarker searchMarker = new SearchMarker(searchLocation);
  map.addMarkers(searchMarker);
  
  searchMarker.setColor(color(255, 0, 0, 100));
  searchMarker.setStrokeColor(color(255, 0, 0));
  searchMarker.setStrokeWeight(4);

  //Generate a new 500px
  fiveapi = new fivehudredAPI(consumerkey,geolocation,radius,results,exclude);
  println("There are: "+fiveapi.imageList.size()+" photos in the array");

  //Arial, 16 point, anti-aliasing on
  f = createFont("Arial",12,true); 
  
  //Load image mask for displaying image icons as circles
  maskImage = loadImage("data/img/circle_white_100.gif");
  maskImage.resize(40,40);
  
  //Controllers
  cp5.addSlider("pointSize")
    .setValue(10)
    .setHeight(15)
    .setPosition(50,860)
    .setRange(10,25);
    
  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("toggle")
     .setPosition(550,860)
     .setSize(50,15)
     .setLabel("Night Photos")
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     ;
     
  cp5.addTextfield("search")
     .setPosition(650,850)
     .setSize(200,20)
     .setFont(createFont("arial",12))
     .setAutoClear(false)
     .setFocus(true)
     .setText("Aurora")
     ;
    
  r = cp5.addRadioButton("radioButton")
         .setPosition(250,860)
         .setSize(15,15)
         .setColorForeground(color(120))
         .setColorActive(color(255))
         .setColorLabel(color(255))
         .setItemsPerRow(3)
         .setSpacingColumn(75)
         .addItem("Show ID",1)
         .addItem("Show Rating",2)
         .addItem("Show Photo",3)
         ; 
     
  for(Toggle t:r.getItems()) {
    t.getCaptionLabel().getStyle().moveMargin(-7,0,0,-3);
    t.getCaptionLabel().getStyle().movePadding(7,0,0,3);
    t.getCaptionLabel().getStyle().backgroundWidth = 45;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }
}

void draw() {
  
  //Draw the map
  map.draw();
  
  //Check Night-Photos or ALL-Photos filter
  if (filter == false) {
    
    //Draw photos as dots on map
    for (ImageInfo part :fiveapi.imageList) {
      
      //Convert photo lat&lon to screen positions
      float[] positions = screenPos(part.lat, part.lon);
      float x= positions[0];
      float y = positions[1];
      
      //Display ID text when toggled on
      if (showid == true) {
        drawID(x, y, part.id);
      }
      
      //Display rating text when toggled on
      if (showrating == true) {
        drawRating(x, y, part.rating);  
      }
      
      //Display rating text when toggled on
      if (showphoto == true) {
        drawPhoto(x, y, part.img);
      }
      
      //Colour code markers to rating of image
      int mappedRating  = reMapper(part.rating);
      colorMode(HSB,360,100,100);
      fill(color(mappedRating, 99, 99));
      
      //Generate markers for photos on map
      colorMode(RGB,255);
      stroke(67);
      strokeWeight(1);
      ellipse(x, y, pointSize, pointSize);
      
      //Generate seach beacons
      String newSearch = cp5.get(Textfield.class,"search").getText();
      if (newSearch.length() > 2) {
        //Display images which match search
        drawSearch(x, y, newSearch, part.name, part.description);
      } else {
        drawSearch(x, y, searchValue, part.name, part.description);
      }
    }
  } else {
    
    //Loop throught the ArrayList of images
    for (ImageInfo part :fiveapi.imageList) {
      
      //Check Photo has date field
      if (part.taken_at != "No Date") {
        
        try {
          
          //Taken_At conversion to GMT/BST
          SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssX");
          TimeZone utc = TimeZone.getTimeZone("UTC");
          df.setTimeZone(utc);
          df.setLenient(false);
          Date date = df.parse(part.taken_at);
          
          //Create calendar
          Calendar c = Calendar.getInstance();
          c.setTime(date);
          
          //Convert Taken_At to intergers
          int t = c.get(Calendar.HOUR_OF_DAY) * 100 + c.get(Calendar.MINUTE);
          
          //Check if photo was taken during the night
          if(sunrise > sunset && t >= sunset && t <= sunrise || sunrise < sunset && (t >= sunset || t <= sunrise)){
          
            //Convert photo lat&lon to screen positions
            float[] positions = screenPos(part.lat, part.lon);
            float x= positions[0];
            float y = positions[1];

            //Display ID text when toggled on
            if (showid == true) {
              drawID(x, y, part.id);
            }
            
            //Display rating text when toggled on
            if (showrating == true) {
              drawRating(x, y, part.rating);  
            }
            
            //Display rating text when toggled on
            if (showphoto == true) {
              drawPhoto(x, y, part.img);
            }
                  
            //Colour code markers to rating of image
            int mappedRating  = reMapper(part.rating);
            colorMode(HSB,360,100,100);
            fill(color(mappedRating, 99, 99));
                  
            //Generate markers for photos on map
            colorMode(RGB,255);
            stroke(67);
            strokeWeight(1);
            ellipse(x, y, pointSize, pointSize);
            
            //Generate seach beacons
            String newSearch = cp5.get(Textfield.class,"search").getText();
            if (newSearch.length() > 2) {
              //Display images which match search
              drawSearch(x, y, newSearch, part.name, part.description);
            } else {
              drawSearch(x, y, searchValue, part.name, part.description);
            }
             
          }
        } catch (Exception e){
          System.out.println(e.getMessage()); 
        }
      }
    }
  }
  
  //Control region
  colorMode(RGB,255);
  fill(56,63,77);
  rect(0, 825, 1440, 75);
  
  //Text
  textFont(f,11);
  fill(255);
  text("Sunset set as: "+sunset,1300,855);
  text("Sunrise set as: "+sunrise,1300,885);
}

//Control the radio state
void keyPressed() {
  switch(key) {
    case('0'): r.deactivateAll(); break;
    case('1'): r.activate(0); break;
    case('2'): r.activate(1); break;
  }
}

//Set states
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(r)) {
    if (theEvent.getValue() == -1) {
      showid = false;
      showrating = false;
      showphoto = false;
    } else if (theEvent.getValue() == 1) {
      showid = true;
      showrating = false;
      showphoto = false;
    } else if (theEvent.getValue() == 2) {
      showid = false;
      showrating = true;
      showphoto = false;
    } else if (theEvent.getValue() == 3) {
      showid = false;
      showrating = false;
      showphoto = true;
    }
    
  }
}

void toggle(boolean theFlag) {
  if(theFlag==true) {
    filter = true;
  } else {
    filter = false;
  }
}

//Convert photo lat&lon to screen positions
float[] screenPos(float temp_lat, float temp_lon) {
  Location Dot = new Location(temp_lat, temp_lon);
  ScreenPosition screenDot = map.getScreenPosition(Dot);
  float[] pos = new float[2];
  pos[0]= screenDot.x;
  pos[1] = screenDot.y;
  return pos;
}

//Draw photos on map
void drawPhoto(float temp_x, float temp_y, PImage temp_img) {
  //Load photo
  temp_img.resize(40,40);
  //Mask photo
  temp_img.mask(maskImage);
  //Display photo
  stroke(129);
  line(temp_x, temp_y, (temp_x+pointSize)+20, (temp_y-pointSize)+20);
  image(temp_img,temp_x+pointSize,temp_y-pointSize);
}

//
void drawSearch(float temp_x, float temp_y, String temp_search, String temp_name, String temp_description) {
  String tags = temp_name+" "+temp_description;
  if (tags.toLowerCase().indexOf(temp_search.toLowerCase()) != -1 ) {
    
    //Generate search beacons
    pushMatrix();
    translate(temp_x, temp_y);
    float radSec = 360 / 60 * millis();
    rotate(radians(radSec*0.03));
    noFill();
    stroke(255, 52, 235);
    strokeWeight(3);
    arc(0, 0, pointSize+5, pointSize+5, radians(0), radians(90)); // lower quarter circle 
    arc(0, 0, pointSize+5, pointSize+5, radians(180), radians(270)); // lower quarter circle  
    popMatrix();

  }
}

//Draw ID Tags on map
void drawID(float temp_x, float temp_y, int temp_id) {
  textFont(f,9);
  fill(67);
  text(temp_id,temp_x+(pointSize/2),temp_y-(pointSize/2));
}

//Draw Rating Tags on map
void drawRating(float temp_x, float temp_y, float temp_rating) {
  textFont(f,9);
  fill(67);
  text(String.valueOf(temp_rating),temp_x+(pointSize/2),temp_y-(pointSize/2));  
}

//Remap rating for colour coding
int reMapper(float temp_rating){
  return int(map(temp_rating, 20, 95, 130, 0));
}