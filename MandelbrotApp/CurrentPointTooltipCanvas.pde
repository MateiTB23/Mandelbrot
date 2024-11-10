import controlP5.*;
import processing.core.PApplet;
import processing.core.PGraphics;

class CurrentPointTooltipCanvas extends Canvas {

  int mx = 0;
  int my = 0;

  public void update(PApplet p) {
    mx = p.mouseX;
    my = p.mouseY;
  }

  public void draw(PGraphics pg) {
    if(currentPoint.Re < model_left || currentPoint.Re > model_right || currentPoint.Im < model_bottom || currentPoint.Im > model_top)
      return;

    pg.fill(255);
    pg.text("(" + currentPoint.Re + ", " + currentPoint.Im + ")", mx + 15 , my + 25);
    double zoomX = (model_right_original-model_left_original)/(model_right-model_left);
    double zoomY = (model_bottom_original-model_top_original)/(model_bottom-model_top);
    pg.text("Zoom: (" + zoomX + ", " +zoomY + ")", mx + 15 , my + 35);
  }
}
