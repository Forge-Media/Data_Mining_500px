/**
* 500px Mapper
*
* A simple application which maps images from 500px (http://www.500px.com)
* 
* by Jeremy Paton, 2016
* www.jeremypaton.com
*
*/

JSONArray cache = new JSONArray();

void apiCacher (JSONObject temp_obj) {
  cache.append(temp_obj.getJSONArray("photos"));
}

void saveapiCache(){
  saveJSONArray(cache, "json/apicache.json");
}