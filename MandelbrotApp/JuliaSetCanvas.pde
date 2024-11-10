import controlP5.*;
import processing.core.PApplet;
import processing.core.PGraphics;

class JuliaSetCanvas extends Canvas {

  private double model_left = -2.0f;
  private double model_right = +2.0f;
  private double model_top = +2.0f;
  private double model_bottom = -2.0f;
  private IPalette palette;
  private double c_re = 0.0f;
  private double c_im = 0.0f;
  private int sliderIterations = 20;

  int x;
  int y;
  int w;
  int h;
  int mx = 0;
  int my = 0;
  
  public JuliaSetCanvas() {
  }

  public void setCurrentModelPoint(double c_re, double c_im) {
    this.c_re = c_re;
    this.c_im = c_im;
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

    //// renders a square with randomly changing colors
    //// make changes here.
    //pg.fill(100);
    //pg.rect(20, y-20, 240, 30);
    //pg.fill(255);
    //pg.text("This text is drawn by MyCanvas", mx,y);
  }

  void drawJuliaSet(PGraphics pg) {

//    println("x=" + x);
//    println("y=" + y);
//    println("w=" + w);
//    println("h=" + h);
//    println("width=" + width);
//    println("height=" + height);

    double scaleX = (model_right-model_left) / this.w;
    double scaleY = (model_top-model_bottom) / this.h;
    color[] colors = palette.getColors();

    for (int x = 0; x < this.w; x++) {
      for (int y = 0; y < this.h; y++) {
        Complex modelPoint = new Complex(model_left + x * scaleX, model_top - y * scaleY);
        int iterations = renderJuliaSet(modelPoint.Re, modelPoint.Im, c_re, c_im, sliderIterations);
        if (iterations == int(iterationSlider.getValue())) {
          pg.set(this.x + x, this.y + y, color(0)); // Mandelbrot set is black
        } else {
          pg.set(this.x + x, this.y + y, colors[iterations % this.palette.getSize()]);
        }
        //println("(" + x + ", " + y + ")=" + pixels[x + y * this.w]);
      }
    }
  }

  int renderJuliaSet(double m_re, double m_im, double c_re, double c_im, int limit) {
    double re = m_re;
    double im = m_im;
    int iteration = 0;
    while (re*re + im*im <= 4 && iteration < limit) {
      double newRe = re * re - im * im + c_re;
      double newIm = 2 * re * im + c_im;
      re = newRe;
      im = newIm;
      iteration++;
    }
    return iteration;
  }
}
