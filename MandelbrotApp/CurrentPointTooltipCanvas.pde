import controlP5.*;
import processing.core.PApplet;
import processing.core.PGraphics;

// klasse der tegner et ToolTip over currentPoint
class CurrentPointTooltipCanvas extends Canvas {

  private int mx = 0; // nuværende mus x koordinat
  private int my = 0; // nuværende mus y koordinat

  // opdaterer mx og my, hver gang musen ændre koordinater
  public void update(PApplet p) {
    mx = p.mouseX;
    my = p.mouseY;
  }

  public void draw(PGraphics pg) {
    // lad være med at tegne noget, hvis currentPoint er udenfor modelens grænser
    if(currentPoint.getRe() < modelLeft || currentPoint.getRe() > modelRight || currentPoint.getIm() < modelBottom || currentPoint.getIm() > modelTop)
      return;

    pg.fill(255); // hvis farve
    pg.text("(" + currentPoint.getRe() + ", " + currentPoint.getIm() + ")", mx + 15 , my + 25); // tegn currentPoints koordinater
    double zoomX = (modelRightOriginal-modelLeftOriginal)/(modelRight-modelLeft);
    double zoomY = (modelBottomOriginal-modelTopOriginal)/(modelBottom-modelTop);
    pg.text("Zoom: (" + zoomX + ", " +zoomY + ")", mx + 15 , my + 35);  // tegn zoom  
  }
}
