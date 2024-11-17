import controlP5.*;
import processing.core.PApplet;
import processing.core.PGraphics;

class MandelbrotSetCanvas extends Canvas {

  JuliaSetCanvas juliaSetCanvas;
  IPalette palette;
  public double cRe = 0.0f;
  public double cIm = 0.0f;
  public int sliderIterations = 20;
  ArrayList<Complex> modelPoints = new ArrayList<Complex>();
  byte circleRadius = 5;
  color circleColor = color(126, 126, 192);

  int x = 0;
  int y = 0;
  int w = 0;
  int h = 0;
  int mx = 0;
  int my = 0;
  // Variables for drag-based panning
  double dragStartX, dragStartY;
  boolean dragging = false;

  public MandelbrotSetCanvas(JuliaSetCanvas juliaSetCanvas) {
    this.juliaSetCanvas = juliaSetCanvas;
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

  public void reset() {
    this.x = 0;
    this.y = 0;
    this.w = 0;
    this.h = 0;
  }

  public void update(PApplet p) {
    float x = p.mouseX;
    float y = p.mouseY;
    currentPoint = view2model(new Point(x, y));
    modelPoints = computePoints(currentPoint.getRe(), currentPoint.getIm(), int(iterationSlider.getValue()));
    juliaSetCanvas.setCurrentModelPoint(currentPoint.getRe(), currentPoint.getIm());
    juliaSetCanvas.setSliderIterations(int(iterationSlider.getValue()));
  }

  public void mouseWheel(MouseEvent event) {
    if (outsideThisCanvas())
      return;
    double e = event.getCount();
    Complex modelPoint = currentPoint;

    if (e<0) {
      modelLeft = modelPoint.getRe() + (modelLeft-modelPoint.getRe())/zoomFactor;
      modelRight = modelPoint.getRe() + (modelRight-modelPoint.getRe())/zoomFactor;
      modelTop = modelPoint.getIm() + (modelTop-modelPoint.getIm())/zoomFactor;
      modelBottom = modelPoint.getIm() + (modelBottom-modelPoint.getIm())/zoomFactor;
    } else {
      modelLeft = modelPoint.getRe() + (modelLeft-modelPoint.getRe())*zoomFactor;
      modelRight = modelPoint.getRe() + (modelRight-modelPoint.getRe())*zoomFactor;
      modelTop = modelPoint.getIm() + (modelTop-modelPoint.getIm())*zoomFactor;
      modelBottom = modelPoint.getIm() + (modelBottom-modelPoint.getIm())*zoomFactor;
    }
  }

  private boolean outsideThisCanvas() {
    boolean outside = currentPoint.getRe() < modelLeft || currentPoint.getRe() > modelRight || currentPoint.getIm() < modelBottom || currentPoint.getIm() > modelTop;
    return outside;
  }

  // Panning using mouse dragging
  public void mousePressed() {
    if (outsideThisCanvas())
      return;
    dragStartX = mouseX;
    dragStartY = mouseY;
    dragging = true;
  }

  public void mouseDragged() {
    if (outsideThisCanvas())
      return;

    if (dragging) {
      double dx = (mouseX - dragStartX) / this.w * (modelRight - modelLeft);
      double dy = (mouseY - dragStartY) / this.h * (modelTop - modelBottom);

      modelLeft -= dx;
      modelRight -= dx;
      modelTop += dy;
      modelBottom += dy;

      dragStartX = mouseX;
      dragStartY = mouseY;
    }
  }

  public void mouseReleased() {
    if (outsideThisCanvas())
      return;
    dragging = false;
  }

  public void draw(PGraphics pg) {
    if (this.w <= 0 || this.h <= 0)
      return;

    pg.fill(0);
    pg.rect(0, 0, width, height);
    drawMandelbrotSet(pg);
    if (drawGrid)
      drawGrid();
    if (drawAxes)
      drawAxes(pg);
    if (drawIterations)
      drawIterations();
  }

  void drawMandelbrotSet(PGraphics pg) {
    scaleX = (modelRight-modelLeft) / this.w;
    scaleY = (modelTop-modelBottom) / this.h;
    color[] colors = palette.getColors();

    for (int x = 0; x < this.w; x++) {
      for (int y = 0; y < this.h; y++) {
        Complex c = new Complex(modelLeft + x * scaleX, modelTop - y * scaleY);
        int iterations = renderMandelbrot(c.getRe(), c.getIm(), int(iterationSlider.getValue()));
        if (iterations == int(iterationSlider.getValue())) {
          pg.set(x, y, color(0)); // Mandelbrot set is black
        } else {
          pg.set(x, y, colors[iterations % this.palette.getSize()]);
        }
      }
    }
  }

  void drawIterations() {
    stroke(circleColor);
    if (modelPoints.size()>0) {
      Point p0 = model2view(modelPoints.get(0));
      circle(p0.getX(), p0.getY(), circleRadius);
    }
    for (int i = 0; i<modelPoints.size()-1; i++) {
      Point first = model2view(modelPoints.get(i));
      Point second = model2view(modelPoints.get(i+1));

      line(first.getX(), first.getY(), second.getX(), second.getY());
      circle(second.getX(), second.getY(), circleRadius);
    }
  }

  // Function to draw x and y axes
  void drawAxes(PGraphics pg) {
    pg.stroke(200);
    pg.strokeWeight(2);

    // Draw X-axis
    Point xAxisLeft = model2view(new Complex(modelLeft, 0));
    Point xAxisRight = model2view(new Complex(modelRight, 0));
    pg.line(xAxisLeft.getX(), xAxisLeft.getY(), xAxisRight.getX(), xAxisRight.getY());

    // Y-axis
    Point yAxisTop = model2view(new Complex(0, modelTop));
    Point yAxisBottom = model2view(new Complex(0, modelBottom));
    pg.line(yAxisTop.getX(), yAxisTop.getY(), yAxisBottom.getX(), yAxisBottom.getY());

    fill(255); // Set the fill color to white
    noStroke(); // Optional: remove the outline

    // Draw X-axis' tip
    triangle(xAxisRight.getX(), xAxisRight.getY(), xAxisRight.getX() - 10, xAxisRight.getY() - 5, xAxisRight.getX() - 10, xAxisRight.getY() + 5);

    // Draw Y-axis' tip
    triangle(yAxisTop.getX(), yAxisTop.getY(), yAxisTop.getX() - 5, yAxisTop.getY() + 10, yAxisTop.getX() + 5, yAxisTop.getY() + 10);
  }
  
  // Draw the grid
  void drawGrid() {
    float gridSpacingX = pow(10, round(log((float)scaleX) / log(10)) + 2); // Grid spacing based on zoom
    float gridSpacingY = pow(10, round(log((float)scaleY) / log(10)) + 2); // Grid spacing based on zoom

    stroke(255, 255, 255, 50); // White with transparency for the grid
    noFill();
    
    // Draw vertical grid lines
    for (float x = ceil((float)(modelLeft / gridSpacingX)) * gridSpacingX; x < modelRight; x += gridSpacingX) {
      float screenX = map(x, (float)modelLeft, (float)modelRight, 0, this.w);
      line(screenX, 0, screenX, this.h);
    }
    
    // Draw horizontal grid lines
    for (float y = ceil((float)(modelBottom / gridSpacingY)) * gridSpacingY; y < modelTop; y += gridSpacingY) {
      float screenY = map(y, (float)modelTop, (float)modelBottom, 0, this.h);
      line(0, screenY, this.w, screenY);
    }
  }

  Complex view2model(Point point) {
    // I know for View: width and height (given by Processing)
    // I know for Model: modelWidth and modelHeight
    // My formulas:
    double re = modelLeft + point.getX()/this.w * (modelRight-modelLeft);
    double im = modelTop - point.getY()/this.h * (modelTop-modelBottom);
    return new Complex(re, im);
  }

  Point model2view(Complex complex) {
    float x = (float)((complex.getRe()-modelLeft)/(modelRight-modelLeft) * this.w);
    float y = (float)((modelTop-complex.getIm())/(modelTop-modelBottom) * this.h);
    return new Point(x, y);
  }

  int renderMandelbrot(double cRe, double cIm, int limit) {

    // f(z) = z^2 + c

    // z = re + i * im
    // im^2 = -1
    //
    // z^2 = (re + i * im)(re + i * im)
    // z^2 = re * re + re * i * im + i * im * re + i * im * i * im
    // z^2 = re^2 + 2 * re * im * i + i^2 * im^2
    // z^2 = (re^2 - im^2) + (2 * re * im) * i

    // c = cRe + cIm * i

    // Mandelbrot betyder at kører f(0), f(1), f(2) ... f(n) og se hvis punkerne forbliver bounded eller vokser mod uendlighed
    // Af praktiske årsager tester vi at f(n) er indefor cirklen med radius 2.


    // f(0) = c
    // f(1) = f(0)^2 + c = c^2 + c
    // f(2) = f(1)^2 + c = ...

    double re = cRe;
    double im = cIm;

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

  ArrayList<Complex> computePoints(double cRe, double cIm, int limit) {
    double re = cRe;
    double im = cIm;
    ArrayList<Complex> modelPointList = new ArrayList<Complex>();
    modelPointList.add(new Complex(re, im));
    int iteration = 0;
    while (re*re + im*im <= 4 && iteration < limit) {
      double newRe = re * re - im * im + cRe;
      double newIm = 2 * re * im + cIm;
      re = newRe;
      im = newIm;
      modelPointList.add(new Complex(re, im));
      iteration++;
    }
    return modelPointList;
  }
}
