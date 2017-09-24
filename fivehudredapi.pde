/**
* 500px Mapper
*
* A simple application which maps images from 500px (http://www.500px.com)
* 
* by Jeremy Paton, 2016
* www.jeremypaton.com
*
*/

public class fivehudredAPI{

  // GLOBAL VARIABLES
  ArrayList<ImageInfo> imageList = new ArrayList<ImageInfo>();
  String url = "https://api.500px.com/v1/photos/search";
  String consumerkey;
  String geo;
  String radius;
  String results;
  String exclude;
  PImage cacheImg;
  
  // CONSTRUCTOR
  fivehudredAPI(String c_consumerkey, String c_geo, String c_radius, String c_results, String c_exclude) {
    consumerkey = c_consumerkey;
    geo = c_geo;
    radius = c_radius;
    results = c_results;
    exclude = c_exclude;
    
    constructURL();
  }
  
  // METHODS
  void constructURL() {    
    String query_url;
    try {
      
      //Create API Query URL
      query_url = url+"?consumer_key="+consumerkey+"&rpp="+results+"&geo="+geo+","+radius+"&exclude="+exclude;
      
      //Echo activity
      if (useAPI == true) {
        println("=== Query api.500px.com ===");
      } else {
        println("=== Query Backup JSON File ===");
      } 
      
      //Run the query
      getData(query_url);
      
    } catch (IndexOutOfBoundsException e) {
        System.err.println("IndexOutOfBoundsException: " + e.getMessage());  
    }
  }
  
  void getData(String query_url) {
    JSONObject temp_json = null;
    JSONObject json = null;
    int total_pages = 0;
    
    try {
      //Run API query statment to 500px
      json = jsonRequest(query_url, 1);
      
      //Get number of pages in query
      total_pages = json.getInt("total_pages");
      
      //Echo number of pages of photos
      println("Number of pages: "+total_pages);
      
      //Sort the JSONObject into a JSONArray of photo data
      JSONArray photoList = json.getJSONArray("photos");
      
      apiCacher(json);
      
      //Construct the array of photos
      setData(photoList);
      
      //If there is more than one page loop through all pages
      if (total_pages > 1 && multicheck == true) {
        println("Multi-check ENABLED, querying multiple pages");
        for (int i = 2; i < 51; i = i+1) {
          //Get pages photos
          temp_json = jsonRequest(query_url, i);
          JSONArray tempList = temp_json.getJSONArray("photos");
          
          setData(tempList);
          
          //If using API create a cache of the request
          if (useAPI == true) {
            apiCacher(temp_json);
          }
        }
      }
      
    saveapiCache();
    
    } catch (RuntimeException e) {
        println("RuntimeException: " + e.getMessage());
    } 
  }
  
  void setData(JSONArray data) {

    //Sort the JSONObject into a JSONArray of photo data
    //JSONArray photoList = data.getJSONArray("photos");
    
    //Echo number of photos which have been returned
    //println("There are: "+data.size()+" photos in the array");
    
    //Loop through the JSONArray of photos
    for (int i = 0; i < data.size(); i++) {
      
      ImageInfo photoObject = new ImageInfo();
      
      JSONObject photo = data.getJSONObject(i);
      
      //Populate PhotoObject with JSONObject data
      photoObject.id = photo.getInt("id");
      photoObject.user_id = photo.getInt("user_id");
      photoObject.name = photo.getString("name");
      photoObject.lat = photo.getFloat("latitude");
      photoObject.lon = photo.getFloat("longitude");
      photoObject.url_s = photo.getString("image_url");
      photoObject.url_p = photo.getString("url");
      photoObject.votes = photo.getInt("votes_count");
      photoObject.rating = photo.getFloat("highest_rating");
      
      //Load photo from URL into object
      //Image Cacher
      File f = new File(dataPath("/cache/"+photo.getInt("id")+".gif"));
      if (f.exists()) {
        
        println("loading image ID: "+photo.getInt("id")+" from CACHE");
        
        cacheImg = loadImage("data/cache/"+photo.getInt("id")+".gif");
        photoObject.img = cacheImg;
      } else {
        
        println("loading image ID: "+photo.getInt("id")+" from URL");
        
        //HTTP 200 checker
        if (exists(photo.getString("image_url"))) {
          
          //Cache the image
          cacheImg = loadImage(photo.getString("image_url"),"gif");
          cacheImg.save("data/cache/"+photo.getInt("id")+".gif");
          photoObject.img = cacheImg;
          
        } else {
          println("Image ID: "+photo.getInt("id")+" Error 404");
          cacheImg = loadImage("data/img/404.gif");
          cacheImg.save("data/cache/"+photo.getInt("id")+".gif");
          photoObject.img = cacheImg;
        }
      }
      
      //Check for null fields
      if (photo.isNull("camera")) {
        photoObject.camera = "No Camera";
      } else {
        photoObject.camera = photo.getString("camera");
      }
      if (photo.isNull("location")) {
        photoObject.location = "No Location";
      } else {
        photoObject.location = photo.getString("location");
      }
      if (photo.isNull("description")) {
        photoObject.description = "No Description";
      } else {
        photoObject.description = photo.getString("description");
      }
      if (photo.isNull("taken_at")) {
        photoObject.taken_at = "No Date";
      } else {
        photoObject.taken_at = photo.getString("taken_at");
      }
            
      
      //Add PhotoObject to the ArrayList<ImageInfo> imageList;
      imageList.add(photoObject);
    }

  }
  
  JSONObject jsonRequest(String temp_url, int page) {
    
    temp_url = temp_url+"&page="+page;
    
    //Echo activity
    println(temp_url);
    
    if (useAPI == true) {
      return loadJSONObject(temp_url);
    } else {
      return loadJSONObject("json/5000.json");
    } 
  }
}