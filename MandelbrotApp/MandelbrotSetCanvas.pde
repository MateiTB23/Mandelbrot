import controlP5.*;
import processing.core.PApplet;
import processing.core.PGraphics;

// klasse der tegner Mandelbrotsættet
class MandelbrotSetCanvas extends Canvas {

  JuliaSetCanvas juliaSetCanvas; // reference til juliaSetCanvas
  IPalette palette; // palette til at tegne Mandelbrotsættet
  public double cRe = 0.0f; // Mandelbrotsættets c's reele del
  public double cIm = 0.0f; // Mandelbrotsættets c's imaginære del
  public int sliderIterations = 20; // hvor mange iterations skal man max beregne
  ArrayList<Complex> modelPoints = new ArrayList<Complex>(); // list med punkterne i modellen til at tegne iterationerne i et sekvens
  byte circleRadius = 5; // for hver iteration i en sekvens, tegnes en cirkel med radius circle Radius
  color circleColor = color(126, 126, 192); // for hver iteration i en sekvens, tegnes en cirkel med denne farve

  int x = 0; // canvas lokations på skærmen
  int y = 0; // canvas lokations på skærmen
  int w = 0; // canvas bredde
  int h = 0; // canvas højde
  int mx = 0; // nuværende mus position på skærmen - x
  int my = 0; // nuværende mus position på skærmen - y
  // Variables for drag-based panning
  double dragStartX, dragStartY;
  boolean dragging = false;

  // constructor
  public MandelbrotSetCanvas(JuliaSetCanvas juliaSetCanvas) {
    this.juliaSetCanvas = juliaSetCanvas;
  }

  // set current model point
  public void setCurrentModelPoint(double cRe, double cIm) {
    this.cRe = cRe;
    this.cIm = cIm;
  }

  // set paletten, som er brut til at tegne iterationerne med
  public void setPalette(IPalette palette) {
    this.palette = palette;
  }

  // set hvor mange iteration man max må bruge
  public void setSliderIterations(int sliderIterations) {
    this.sliderIterations = sliderIterations;
  }

  // set canvas lokation på skærmen
  public void setPosition(int x, int y) {
    this.x = x;
    this.y = y;
  }

  // set størrelsen for canvas
  public void setSize(int w, int h) {
    this.w = w;
    this.h = h;
  }

  // reset x, y, w, h
  public void reset() {
    this.x = 0;
    this.y = 0;
    this.w = 0;
    this.h = 0;
  }

  // callback fra processing for at opdatere mus koordinaterne
  public void update(PApplet p) {
    float x = p.mouseX;
    float y = p.mouseY;
    currentPoint = view2model(new Point(x, y));
    modelPoints = computePoints(currentPoint.getRe(), currentPoint.getIm(), int(iterationSlider.getValue()));
    juliaSetCanvas.setCurrentModelPoint(currentPoint.getRe(), currentPoint.getIm()); // informerer juliaSetCanvas at currentPoint blev ændret
    juliaSetCanvas.setSliderIterations(int(iterationSlider.getValue())); // informerer juliaSetCanvas, hvad antal iterationer er
  }

  // mus event brugt til at zoome ind/ud
  public void mouseWheel(MouseEvent event) {
    // hvis evenet ikke er for MandelbrotSetCanvas, så return
    if (outsideThisCanvas())
      return;
    double e = event.getCount();
    Complex modelPoint = currentPoint;

    // zoom ind eller ud? opdatere model dimensionerne
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

  // methode som beregner, hvis currentPoint er i modellen
  // (Mandelbrotsættet, som man ser det på skærmen) eller ej 
  private boolean outsideThisCanvas() {
    boolean outside = currentPoint.getRe() < modelLeft || currentPoint.getRe() > modelRight || currentPoint.getIm() < modelBottom || currentPoint.getIm() > modelTop;
    return outside;
  }

  // Når brugeren trykker på musen, set dragging true
  public void mousePressed() {
    if (outsideThisCanvas()) // hvis eventet ikke er for MandelbrotSetCanvas, så return
      return;
    dragStartX = mouseX;
    dragStartY = mouseY;
    dragging = true;
  }

  // Metode brugt til at flytte (translate) modellen
  public void mouseDragged() {
    if (outsideThisCanvas()) // hvis eventet ikke er for MandelbrotSetCanvas, så return
      return;

    // tager effekt kun mens dragger
    if (dragging) {
      // beregn hvor meget man har flyttet musen ift modellen
      double dx = (mouseX - dragStartX) / this.w * (modelRight - modelLeft);
      double dy = (mouseY - dragStartY) / this.h * (modelTop - modelBottom);

      // foretage ændringer
      modelLeft -= dx;
      modelRight -= dx;
      modelTop += dy;
      modelBottom += dy;

      dragStartX = mouseX;
      dragStartY = mouseY;
    }
  }

  // når brugeren slipper museknappen, set dragging false
  public void mouseReleased() {
    if (outsideThisCanvas())
      return;
    dragging = false;
  }

  // hovedtegningslogik
  public void draw(PGraphics pg) {
    // det kan ske, før canvas er initiliaseret at draw() er kaldt,
    // hvis w eller h ikke er initialiseret return 
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

  // tegn Mandelbrotsættet
  void drawMandelbrotSet(PGraphics pg) {
    scaleX = (modelRight-modelLeft) / this.w;
    scaleY = (modelTop-modelBottom) / this.h;
    color[] colors = palette.getColors();

    // loop over pixel i canvas
    for (int x = 0; x < this.w; x++) {
      for (int y = 0; y < this.h; y++) {
        // beregn tilsvarende complekstal
        Complex c = new Complex(modelLeft + x * scaleX, modelTop - y * scaleY);
        // beregn antal iterationer indtil punktet divergerer eller rammer max iterations
        int iterations = renderMandelbrot(c.getRe(), c.getIm(), int(iterationSlider.getValue()));
        // map antal iteration til farve
        if (iterations == int(iterationSlider.getValue())) {
          pg.set(x, y, color(0)); // Mandelbrot set is black
        } else {
          pg.set(x, y, colors[iterations % this.palette.getSize()]);
        }
      }
    }
  }

  // tegn iterationer
  void drawIterations() {
    stroke(circleColor);
    
    // tegn nuværende punkts cirkle
    if (modelPoints.size()>0) {
      Point p0 = model2view(modelPoints.get(0));
      circle(p0.getX(), p0.getY(), circleRadius);
    }
    
    // for hvert par punkter tegn en linje og for hvert andet punkt tegn en cirkel
    for (int i = 0; i<modelPoints.size()-1; i++) {
      Point first = model2view(modelPoints.get(i));
      Point second = model2view(modelPoints.get(i+1));

      line(first.getX(), first.getY(), second.getX(), second.getY());
      circle(second.getX(), second.getY(), circleRadius);
    }
  }

  // metode til at tegne x og y akser
  void drawAxes(PGraphics pg) {
    pg.stroke(200);
    pg.strokeWeight(2);

    // tegn X-akse
    Point xAxisLeft = model2view(new Complex(modelLeft, 0));
    Point xAxisRight = model2view(new Complex(modelRight, 0));
    pg.line(xAxisLeft.getX(), xAxisLeft.getY(), xAxisRight.getX(), xAxisRight.getY());

    // tegn Y-akse
    Point yAxisTop = model2view(new Complex(0, modelTop));
    Point yAxisBottom = model2view(new Complex(0, modelBottom));
    pg.line(yAxisTop.getX(), yAxisTop.getY(), yAxisBottom.getX(), yAxisBottom.getY());

    fill(255); // hvid farve
    noStroke(); // fjern outline

    // tegn X-aksens spids
    triangle(xAxisRight.getX(), xAxisRight.getY(), xAxisRight.getX() - 10, xAxisRight.getY() - 5, xAxisRight.getX() - 10, xAxisRight.getY() + 5);

    // tegn Y-aksen spids
    triangle(yAxisTop.getX(), yAxisTop.getY(), yAxisTop.getX() - 5, yAxisTop.getY() + 10, yAxisTop.getX() + 5, yAxisTop.getY() + 10);
  }
  
  // tegn gitter
  void drawGrid() {
    float gridSpacingX = pow(10, round(log((float)scaleX) / log(10)) + 2); // Grid spacing based on zoom
    float gridSpacingY = pow(10, round(log((float)scaleY) / log(10)) + 2); // Grid spacing based on zoom

    stroke(255, 255, 255, 50); // White with transparency for the grid
    noFill();
    
    // tegn lodret gitter linjer
    for (float x = ceil((float)(modelLeft / gridSpacingX)) * gridSpacingX; x < modelRight; x += gridSpacingX) {
      float screenX = map(x, (float)modelLeft, (float)modelRight, 0, this.w);
      line(screenX, 0, screenX, this.h);
    }
    
    // tegn vandret gitter linjer
    for (float y = ceil((float)(modelBottom / gridSpacingY)) * gridSpacingY; y < modelTop; y += gridSpacingY) {
      float screenY = map(y, (float)modelTop, (float)modelBottom, 0, this.h);
      line(0, screenY, this.w, screenY);
    }
  }

  // metode til at mappe et punkt fra view til et punkt i modellen
  Complex view2model(Point point) {
    // Jeg kender til View: bredde og højde (givet ved behandling)
    // Jeg kender til Model: modelWidth og modelHeight
    // Mine formler:
    double re = modelLeft + point.getX()/this.w * (modelRight-modelLeft);
    double im = modelTop - point.getY()/this.h * (modelTop-modelBottom);
    return new Complex(re, im);
  }

  // metode til at mappe et punkt fra modellen til et punkt i viewet  
  Point model2view(Complex complex) {
    float x = (float)((complex.getRe()-modelLeft)/(modelRight-modelLeft) * this.w);
    float y = (float)((modelTop-complex.getIm())/(modelTop-modelBottom) * this.h);
    return new Point(x, y);
  }

  // metode til at recursivt kalde Mandelbrot funktionen z_n+1=z_n^2+c
  // iterativt for bestemt cRe og cIm og max antal iterationer, her kaldt limit
  // Denne metode returnerer enten antallet af iterationer, indtil sekvensen
  // blev divergent (gik udenfor cirklene med radius 2) eller limit blev ramt
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

  // beregner alle punker i en sekvens for bestemt cRe, cIm og limit
  // og returnerer disse
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
