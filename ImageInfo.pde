class ImageInfo {
  
  // GLOBAL VARIABLES
  PImage img;
  int id;
  int user_id;
  String name;
  String description;
  String camera;
  String location;
  float lat;
  float lon;
  String url_s;
  String url_p;
  int votes;
  String taken_at;
  float rating;
  
  // CONSTRUCTOR
  // How you build the class
  // assign values to variables
  // runs just one time when you initialize the class
  // in a way it's similar to setup() 
  
  // METHODS
  void display(){
    println("Image ID: "+id);
    //println("User ID: "+userid);
    //println("Image Name: "+name);
    //println("Image Description: "+description);
    //println("Camera: "+camera);
    //println("Location: "+location);
    //println("Latitude: "+lat);
    //println("Longitude: "+lon);
    //println("URL: "+url_s);
    //println("Site URL: "+url_p);
  };
}