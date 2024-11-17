import controlP5.*;
import processing.core.PApplet;
import processing.core.PGraphics;

class CurrentPointTooltipCanvas extends Canvas {

  private int mx = 0;
  private int my = 0;

  public void update(PApplet p) {
    mx = p.mouseX;
    my = p.mouseY;
  }

  public void draw(PGraphics pg) {
    if(currentPoint.getRe() < modelLeft || currentPoint.getRe() > modelRight || currentPoint.getIm() < modelBottom || currentPoint.getIm() > modelTop)
      return;

    pg.fill(255);
    pg.text("(" + currentPoint.getRe() + ", " + currentPoint.getIm() + ")", mx + 15 , my + 25);
    double zoomX = (modelRightOriginal-modelLeftOriginal)/(modelRight-modelLeft);
    double zoomY = (modelBottomOriginal-modelTopOriginal)/(modelBottom-modelTop);
    pg.text("Zoom: (" + zoomX + ", " +zoomY + ")", mx + 15 , my + 35);
  }
}
