import controlP5.*;
import processing.core.PApplet;
import processing.core.PGraphics;

class MandelbrotSetCanvas extends Canvas {

  JuliaSetCanvas juliaSetCanvas;
  IPalette palette;
  public double c_re = 0.0f;
  public double c_im = 0.0f;
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
    modelPoints = computePoints(currentPoint.Re, currentPoint.Im, int(iterationSlider.getValue()));
    juliaSetCanvas.setCurrentModelPoint(currentPoint.Re, currentPoint.Im);
    juliaSetCanvas.setSliderIterations(int(iterationSlider.getValue()));
  }

  public void mouseWheel(MouseEvent event) {
    if (outsideThisCanvas())
      return;
    double e = event.getCount();
    Complex modelPoint = currentPoint;

    //println(e);

    if (e<0) {
      model_left = modelPoint.Re + (model_left-modelPoint.Re)/zoomFactor;
      model_right = modelPoint.Re + (model_right-modelPoint.Re)/zoomFactor;
      model_top = modelPoint.Im + (model_top-modelPoint.Im)/zoomFactor;
      model_bottom = modelPoint.Im + (model_bottom-modelPoint.Im)/zoomFactor;
    } else {
      model_left = modelPoint.Re + (model_left-modelPoint.Re)*zoomFactor;
      model_right = modelPoint.Re + (model_right-modelPoint.Re)*zoomFactor;
      model_top = modelPoint.Im + (model_top-modelPoint.Im)*zoomFactor;
      model_bottom = modelPoint.Im + (model_bottom-modelPoint.Im)*zoomFactor;
    }
    //println(zoomFactor + "(" + model_left + ", " + model_right + ", " + model_bottom + ", " + model_top + ")");
  }

  private boolean outsideThisCanvas() {
    boolean outside = currentPoint.Re < model_left || currentPoint.Re > model_right || currentPoint.Im < model_bottom || currentPoint.Im > model_top;
    //println("(" + currentPoint.Re + ", " + currentPoint.Im + ") (" + model_left + ", " + model_right + ", " + model_bottom + ", " + model_top + ") => outside: " + outside);
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
      double dx = (mouseX - dragStartX) / this.w * (model_right - model_left);
      double dy = (mouseY - dragStartY) / this.h * (model_top - model_bottom);

      model_left -= dx;
      model_right -= dx;
      model_top += dy;
      model_bottom += dy;

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
    scaleX = (model_right-model_left) / this.w;
    scaleY = (model_top-model_bottom) / this.h;
    color[] colors = palette.getColors();

    for (int x = 0; x < this.w; x++) {
      for (int y = 0; y < this.h; y++) {
        Complex c = new Complex(model_left + x * scaleX, model_top - y * scaleY);
        int iterations = renderMandelbrot(c.Re, c.Im, int(iterationSlider.getValue()));
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
      circle(p0.X, p0.Y, circleRadius);
    }
    for (int i = 0; i<modelPoints.size()-1; i++) {
      Point first = model2view(modelPoints.get(i));
      Point second = model2view(modelPoints.get(i+1));

      line(first.X, first.Y, second.X, second.Y);
      circle(second.X, second.Y, circleRadius);
    }
  }

  // Function to draw x and y axes
  void drawAxes(PGraphics pg) {
    pg.stroke(200);
    pg.strokeWeight(2);

    // Draw X-axis
    Point xAxisLeft = model2view(new Complex(model_left, 0));
    Point xAxisRight = model2view(new Complex(model_right, 0));
    pg.line(xAxisLeft.X, xAxisLeft.Y, xAxisRight.X, xAxisRight.Y);

    // Y-axis
    Point yAxisTop = model2view(new Complex(0, model_top));
    Point yAxisBottom = model2view(new Complex(0, model_bottom));
    pg.line(yAxisTop.X, yAxisTop.Y, yAxisBottom.X, yAxisBottom.Y);

    fill(255); // Set the fill color to white
    noStroke(); // Optional: remove the outline

    // Draw X-axis' tip
    triangle(xAxisRight.X, xAxisRight.Y, xAxisRight.X - 10, xAxisRight.Y - 5, xAxisRight.X - 10, xAxisRight.Y + 5);

    // Draw Y-axis' tip
    triangle(yAxisTop.X, yAxisTop.Y, yAxisTop.X - 5, yAxisTop.Y + 10, yAxisTop.X + 5, yAxisTop.Y + 10);
  }
  
  // Draw the grid
  void drawGrid() {
    float gridSpacingX = pow(10, round(log((float)scaleX) / log(10)) + 2); // Grid spacing based on zoom
    float gridSpacingY = pow(10, round(log((float)scaleY) / log(10)) + 2); // Grid spacing based on zoom
    
    //println("(" + gridSpacingX + ", " + gridSpacingY + ")");
    
    stroke(255, 255, 255, 50); // White with transparency for the grid
    noFill();
    
    // Draw vertical grid lines
    for (float x = ceil((float)(model_left / gridSpacingX)) * gridSpacingX; x < model_right; x += gridSpacingX) {
      float screenX = map(x, (float)model_left, (float)model_right, 0, this.w);
      line(screenX, 0, screenX, this.h);
    }
    
    // Draw horizontal grid lines
    for (float y = ceil((float)(model_bottom / gridSpacingY)) * gridSpacingY; y < model_top; y += gridSpacingY) {
      float screenY = map(y, (float)model_top, (float)model_bottom, 0, this.h);
      line(0, screenY, this.w, screenY);      
      //println("(" + 0 + ", " + screenY + ") -> (" + this.w + ", " + screenY + ")");
    }
  }

  Complex view2model(Point point) {
    // I know for View: width and height (given by Processing)
    // I know for Model: model_width and model_height (local variables)
    // My formulas:
    double re = model_left + point.X/this.w * (model_right-model_left);
    double im = model_top - point.Y/this.h * (model_top-model_bottom);
    return new Complex(re, im);
  }

  Point model2view(Complex complex) {
    float x = (float)((complex.Re-model_left)/(model_right-model_left) * this.w);
    float y = (float)((model_top-complex.Im)/(model_top-model_bottom) * this.h);
    return new Point(x, y);
  }

  int renderMandelbrot(double c_re, double c_im, int limit) {

    // f(z) = z^2 + c

    // z = re + i * im
    // im^2 = -1
    //
    // z^2 = (re + i * im)(re + i * im)
    // z^2 = re * re + re * i * im + i * im * re + i * im * i * im
    // z^2 = re^2 + 2 * re * im * i + i^2 * im^2
    // z^2 = (re^2 - im^2) + (2 * re * im) * i

    // c = c_re + c_im * i

    // Mandelbrot betyder at kører f(0), f(1), f(2) ... f(n) og se hvis punkerne forbliver bounded eller vokser mod uendlighed
    // Af praktiske årsager tester vi at f(n) er indefor cirklen med radius 2.


    // f(0) = c
    // f(1) = f(0)^2 + c = c^2 + c
    // f(2) = f(1)^2 + c = ...

    double re = c_re;
    double im = c_im;

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

  ArrayList<Complex> computePoints(double c_re, double c_im, int limit) {
    double re = c_re;
    double im = c_im;
    ArrayList<Complex> modelPointList = new ArrayList<Complex>();
    modelPointList.add(new Complex(re, im));
    int iteration = 0;
    while (re*re + im*im <= 4 && iteration < limit) {
      double newRe = re * re - im * im + c_re;
      double newIm = 2 * re * im + c_im;
      re = newRe;
      im = newIm;
      modelPointList.add(new Complex(re, im));
      iteration++;
    }
    return modelPointList;
  }
}
