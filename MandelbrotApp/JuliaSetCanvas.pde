import controlP5.*;// Importer ControlP5 library for GUI controls som buttons and sliders
import processing.core.PApplet;
import processing.core.PGraphics;

// klasse der tegner Juliasættet
class JuliaSetCanvas extends Canvas {

  // JuliaSetCanvas har sin egen model
  private double modelLeft = -2.0f;
  private double modelRight = +2.0f;
  private double modelTop = +2.0f;
  private double modelBottom = -2.0f;
  // Paletten som er brugt til at tegne med
  private IPalette palette;
  // Mandelbrot c punktet
  private double cRe = 0.0f;
  private double cIm = 0.0f;
  // Antal iterationer man skal bruge
  private int sliderIterations = 20;

  int x; // canvas x lokation på skærmen
  int y; // canvas y lokation på skærmen
  int w; // canvas bredde
  int h; // canvas højde
  
  public JuliaSetCanvas() {
  }
  
  // Man bruger det her methode til at sætte current point re og im
  public void setCurrentModelPoint(double cRe, double cIm) {
    this.cRe = cRe;
    this.cIm = cIm;
  }
  
  // Set palette
  public void setPalette(IPalette palette) {
    this.palette = palette;
  }

  // Set itereationerne antal
  public void setSliderIterations(int sliderIterations) {
    this.sliderIterations = sliderIterations;
  }

  // Set canvas lokation på skærmen
  public void setPosition(int x, int y) {
    this.x = x;
    this.y = y;
  }

  // Set canvas størrelse
  public void setSize(int w, int h) {
    this.w = w;
    this.h = h;
  }

  // Tegne rutine
  public void draw(PGraphics pg) {
    if (this.w <= 0 || this.h <= 0)
      return;
    drawJuliaSet(pg);
  }

  // Tegner Juliasættet
  void drawJuliaSet(PGraphics pg) {
    double scaleX = (modelRight-modelLeft) / this.w;
    double scaleY = (modelTop-modelBottom) / this.h;
    color[] colors = palette.getColors();

    // looper over alle punkterne, som hører til canvas
    for (int x = 0; x < this.w; x++) {
      for (int y = 0; y < this.h; y++) {
        // oversat view to model punkt
        Complex modelPoint = new Complex(modelLeft + x * scaleX, modelTop - y * scaleY);
        // render Juliasættet punkt og få tilbage hvor mange iterationer indtil punktet er ikke længere afgrænset
        int iterations = renderJuliaSet(modelPoint.getRe(), modelPoint.getIm(), cRe, cIm, sliderIterations);
        if (iterations == int(iterationSlider.getValue())) {
          pg.set(this.x + x, this.y + y, color(0)); // brug sort hvis indenfor Mandebrotsættet
        } else {
          pg.set(this.x + x, this.y + y, colors[iterations % this.palette.getSize()]); // brug frave fra paletten
        }
      }
    }
  }

  // beregn hvor mange iteration vil det tage et bestemt punkt til at blive
  // afgrænset (gå ud af cirklen med radius 2) eller ramme iterations grænsen
  // kaldt limit
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
