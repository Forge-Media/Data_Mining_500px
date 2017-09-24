import processing.core.*;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;
 
public class SearchMarker extends SimplePointMarker {
  
  public SearchMarker(Location location) {
    super(location);
  }
 
  public void draw(PGraphics pg, float x, float y) {
    pg.strokeWeight(2);
    pg.stroke(255, 0, 230);
    pg.noFill();
    pg.ellipse(x, y, 10, 10);
  }
}