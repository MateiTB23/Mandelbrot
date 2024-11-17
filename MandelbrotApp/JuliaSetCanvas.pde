import controlP5.*;
import processing.core.PApplet;
import processing.core.PGraphics;

class JuliaSetCanvas extends Canvas {

  private double modelLeft = -2.0f;
  private double modelRight = +2.0f;
  private double modelTop = +2.0f;
  private double modelBottom = -2.0f;
  private IPalette palette;
  private double cRe = 0.0f;
  private double cIm = 0.0f;
  private int sliderIterations = 20;

  int x;
  int y;
  int w;
  int h;
  int mx = 0;
  int my = 0;
  
  public JuliaSetCanvas() {
  }

  public void setCurrentModelPoint(double cRe, double cIm) {
    this.cRe = cRe;
    this.cIm = cIm;
  }
  
  public void setPalette(IPalette palette) {
    this.palette = palette;
  }

  public void setSliderIterations(int sliderIterations) {
    this.sliderIterations = sliderIterations;
  }

  public void setPosition(int x, int y) {
    this.x = x;
    this.y = y;
  }

  public void setSize(int w, int h) {
    this.w = w;
    this.h = h;
  }

  public void update(PApplet p) {
    mx = p.mouseX;
    my = p.mouseY;
  }

  public void draw(PGraphics pg) {
    if (this.w <= 0 || this.h <= 0)
      return;
    drawJuliaSet(pg);
  }

  void drawJuliaSet(PGraphics pg) {
    double scaleX = (modelRight-modelLeft) / this.w;
    double scaleY = (modelTop-modelBottom) / this.h;
    color[] colors = palette.getColors();

    for (int x = 0; x < this.w; x++) {
      for (int y = 0; y < this.h; y++) {
        Complex modelPoint = new Complex(modelLeft + x * scaleX, modelTop - y * scaleY);
        int iterations = renderJuliaSet(modelPoint.getRe(), modelPoint.getIm(), cRe, cIm, sliderIterations);
        if (iterations == int(iterationSlider.getValue())) {
          pg.set(this.x + x, this.y + y, color(0)); // Mandelbrot set is black
        } else {
          pg.set(this.x + x, this.y + y, colors[iterations % this.palette.getSize()]);
        }
      }
    }
  }

  int renderJuliaSet(double mRe, double mIm, double cRe, double cIm, int limit) {
    double re = mRe;
    double im = mIm;
    int iteration = 0;
    while (re*re + im*im <= 4 && iteration < limit) {
      double newRe = re * re - im * im + cRe;
      double newIm = 2 * re * im + cIm;
      re = newRe;
      im = newIm;
      iteration++;
    }
    return iteration;
  }
}
