import controlP5.*; // Importer ControlP5 library for GUI controls som buttons and sliders

private ControlP5 cp5; //ControlP5 variabel cp5
private Slider iterationSlider; //slider til iterationer
private JuliaSetCanvas juliaSetCanvas; // tegne området for juliaSetCanvas objekt fra klassen JuliaSetCanvas
private MandelbrotSetCanvas mandelbrotSetCanvas; // tegne området for mandelbrotSetCanvas objekt fra klassen MandelbrotSetCanvas
private CurrentPointTooltipCanvas currentPointTooltipCanvas; // tool tip til punktet hvor markør er fra objekt fra CurrentPointTooltipCanvas klasse
 
private DropdownList paletteDropdownList; //drop down liste til forskellige farve paletter
private DropdownList jumpToDropdownList;  //drop down liste til forskellige lokationer man kan teleportere

//forskellige farve paletter til tegning af mandelbrot og julia-sæt, se evt klassen Palletes
private IPalette palette0 = new Palette0();
private IPalette palette1 = new Palette1();
private IPalette palette2 = new Palette2();
private IPalette palette3 = new Palette3();
private IPalette currentPalette = palette0; // aktuel farve palette
private Complex currentPoint;
// model's dimensioner i den komplekse plan
private double modelLeft; 
private double modelRight;
private double modelTop;
private double modelBottom;
// model's dimensioner i den komplekse plan (default værdier)
private double modelLeftOriginal = -3d;
private double modelRightOriginal = +3d;
private double modelTopOriginal = +3d;
private double modelBottomOriginal = -3d;
private double zoomFactor = 1.05d; // zoom faktor
private double scaleX = 1.0d; // skalafaktor for x-aksen
private double scaleY = 1.0d; // skalafaktor for x-aksen
private boolean drawAxes = false; // bool som angiver, om akserne skal tegnes
private boolean drawGrid = false; // bool som angiver, om gitter skal tegnes
private boolean drawIterations = false;  // bool som angiver, om akserne iterationerne skal tegnes

void setup() {
  resetModel();

  // initialisere værdierne
  int windowWidth = 1280;
  int windowHeight = 720;
  int delta = windowWidth-windowHeight;
  int juliaSetCanvasWidth = delta;
  int juliaSetCanvasHeight = delta;
  int mandelbrotSetCanvasWidth = windowHeight;
  int mandelbrotSetCanvasHeight = windowHeight;
  int widgetWidth = 200;
  int widgetHeight = 25;
  int widgetMargin = 10;

  size(1280, 720); // vindue størrelse
  cp5 = new ControlP5(this); // instansiere CP5

  // instansiere JuliaSetCanvas og placere det på skærmen
  juliaSetCanvas = new JuliaSetCanvas();
  juliaSetCanvas.setPosition(mandelbrotSetCanvasWidth, 0);
  juliaSetCanvas.setSize(juliaSetCanvasWidth, juliaSetCanvasHeight);
  juliaSetCanvas.setPalette(currentPalette);

  // instansiere MandelbrotSetCanvas og placere det på skærmen
  mandelbrotSetCanvas = new MandelbrotSetCanvas(juliaSetCanvas);
  mandelbrotSetCanvas.setPosition(0, 0);
  mandelbrotSetCanvas.setSize(mandelbrotSetCanvasWidth, mandelbrotSetCanvasHeight);
  mandelbrotSetCanvas.setPalette(currentPalette);

  // instansiere CurrentPointTooltipCanvas og placere det på skærmen
  currentPointTooltipCanvas = new CurrentPointTooltipCanvas();

  // tilføj de tre canvas til cp5
  cp5.addCanvas(mandelbrotSetCanvas);
  cp5.addCanvas(juliaSetCanvas);
  cp5.addCanvas(currentPointTooltipCanvas);

  // opret iteration slider
  iterationSlider = cp5.addSlider("Iterations")
    .setRange(0, this.currentPalette.getSize() * 4)
    .setValue(20)
    .setPosition(mandelbrotSetCanvasWidth, juliaSetCanvasHeight)
    .setSize(widgetWidth, widgetHeight)
    .setNumberOfTickMarks(this.currentPalette.getSize())
    .showTickMarks(true)
    .snapToTickMarks(true);

  // opret "reset model" knap
  cp5.addButton("reset") // Button name (also used as a callback method)
    .setPosition(mandelbrotSetCanvasWidth, juliaSetCanvasHeight + widgetHeight + widgetMargin) // Position (x, y)
    .setSize(widgetWidth / 2 - 5, widgetHeight) // Size (width, height)
    .setLabel("Reset the model") // Button label
    .getCaptionLabel() // Access the label settings
    .align(ControlP5.CENTER, ControlP5.CENTER); // Align label to the center, centered vertically

  // opret toggle knap for at vise/skjule gitter
  cp5.addToggle("drawGrid") // Toggle name (also used as a callback)
    .setPosition(mandelbrotSetCanvasWidth + widgetWidth / 2 + 5, juliaSetCanvasHeight + widgetHeight + widgetMargin) // Position on canvas
    .setSize(widgetWidth / 2 - 5, widgetHeight) // Width and height
    .setValue(false) // Initial state (false = off)
    .setLabel("Draw Grid") // Label displayed on the toggle
    .getCaptionLabel() // Access the label settings
    .align(ControlP5.CENTER, ControlP5.CENTER); // Align label to the center, centered vertically

  // opret toggle knap for at vise/skjule akserne
  cp5.addToggle("drawAxes") // Toggle name (also used as a callback)
    .setPosition(mandelbrotSetCanvasWidth, juliaSetCanvasHeight + 2 * (widgetHeight + widgetMargin)) // Position on canvas
    .setSize(widgetWidth / 2 - 5, widgetHeight) // Width and height
    .setValue(false) // Initial state (false = off)
    .setLabel("Draw Axes") // Label displayed on the toggle
    .getCaptionLabel() // Access the label settings
    .align(ControlP5.CENTER, ControlP5.CENTER); // Align label to the center, centered vertically

  // opret toggle knap for at vise/skjule iterationerne
  cp5.addToggle("drawIterations") // Toggle name (also used as a callback)
    .setPosition(mandelbrotSetCanvasWidth + widgetWidth / 2 + 5, juliaSetCanvasHeight + 2 * (widgetHeight + widgetMargin)) // Position on canvas
    .setSize(widgetWidth / 2 - 5, widgetHeight) // Width and height
    .setValue(false) // Initial state (false = off)
    .setLabel("Draw Iterations") // Label displayed on the toggle
    .getCaptionLabel() // Access the label settings
    .align(ControlP5.CENTER, ControlP5.CENTER); // Align label to the center, centered vertically

  // opret dropdown list for at vælge paletter
  paletteDropdownList = cp5.addDropdownList("paletteDropdownList")
    .setPosition(mandelbrotSetCanvasWidth, juliaSetCanvasHeight + 3 * (widgetHeight + widgetMargin))
    .setSize(widgetWidth, widgetHeight * 3)
    .setLabel("Select Palette")
    .addItem("Palette 1 (7 colors)", 0)
    .addItem("Palette 2 (Ultra Fractal)", 1)
    .addItem("Palette 3 (Grayscale)", 2)
    .addItem("Palette 4 (Red-Blue)", 3)
    .setValue(0);

  // opret dropdown list for at vælge spændende steder på Mandelbrotsættet
  jumpToDropdownList = cp5.addDropdownList("jumpToDropdownList")
    .setPosition(mandelbrotSetCanvasWidth + widgetWidth + widgetMargin, juliaSetCanvasHeight + 1 * (widgetHeight + widgetMargin))
    .setSize(widgetWidth, widgetHeight * 5)
    .setLabel("Jump to ...")
    .addItem("Home", 0)
    .addItem("Julia Island", 1)
    .addItem("Seahorse Valley", 2)
    .addItem("Starfish", 3)
    .addItem("Sun", 4)
    .addItem("Tendrils", 5)
    .addItem("Tree", 6)
    .addItem("Flower", 7)
    .addItem("Matei 1", 8)
    .addItem("Matei 2", 9)
    .setValue(0);
}

void draw() {
  if (height <= 0 || width <= 0)
    return;
}

public void reset() {
  resetModel();
}

// Callback for vise/skjule akserne
void drawAxes(boolean state) {
  drawAxes = state; // Update state based on toggle
}

// Callback for vise/skjule gitter
void drawGrid(boolean state) {
  drawGrid = state; // Update state based on toggle
}


// Callback for vise/skjule iterationer
void drawIterations(boolean state) {
  drawIterations = state; // Update state based on toggle
}

// Reset modelen til default værdier
private void resetModel() {
  this.modelLeft = modelLeftOriginal;
  this.modelRight = modelRightOriginal;
  this.modelTop = modelTopOriginal;
  this.modelBottom = modelBottomOriginal;
  this.zoomFactor = 1.05f;
  if (this.iterationSlider != null)
    this.iterationSlider.setValue(20f);
}

// Videresend mousePressed til MandelbrotSetCanvas
void mousePressed() {
  mandelbrotSetCanvas.mousePressed();
}

// Videresend mouseRelease til MandelbrotSetCanvas
void mouseReleased() {
  mandelbrotSetCanvas.mouseReleased();
}

// Videresend mouseDragged til MandelbrotSetCanvas
void mouseDragged() {
  mandelbrotSetCanvas.mouseDragged();
}

// Videresend mouseWheel til MandelbrotSetCanvas
void mouseWheel(MouseEvent event) {
  mandelbrotSetCanvas.mouseWheel(event);
}

// Håndterer events fra forskellige controller
void controlEvent(ControlEvent event)
{
  if (event.isFrom(paletteDropdownList))
  {
    switch ((int) event.getValue()) { //skift paletten
    case 0:
      currentPalette = palette0;
      break;
    case 1:
      currentPalette = palette1;
      break;
    case 2:
      currentPalette = palette2;
      break;
    case 3:
      currentPalette = palette3;
      break;
    }
    // den nye palette er applied på de to canvas
    mandelbrotSetCanvas.setPalette(currentPalette);
    juliaSetCanvas.setPalette(currentPalette);
  }
  
  if (event.isFrom(jumpToDropdownList))
  {
    double re = 0.0d;
    double im = 0.0d;
    int iteration = 1;
    double zoom = 100;

    // baseret på hvad brugeren vælger i dropdown, så ændre man kooridaterne
    // og zoom faktor i modellen, så man visualiserer det, som brugeren ønsker sig
    switch ((int) event.getValue()) {
    case 0: // Home
      re = 0.0d;
      im = 0.0d;
      iteration = 20;
      zoom = 120;
      break;
    case 1: // Julia Island    
      re = -1.768778833d;
      im = 0.001738996d;
      iteration = 550;
      zoom = 500000000;
      break;
    case 2: // Seahorse Valley
      re = -0.743517833d;
      im = 0.127094578d;
      iteration = 400;
      zoom = 45355;
      break;
    case 3: // Starfish
      re = -0.374004139d;
      im = -0.659792175d;
      iteration = 376;
      zoom = 193701;
      break;
    case 4: // Sun
      re = -0.776592847d;
      im = 0.136640848d;
      iteration = 400;
      zoom = 23312976;
      break;
    case 5: // Tendrils    
      re = -0.226266648d;
      im = -1.11617444d;
      iteration = 400;
      zoom = 297514722;
      break;
    case 6: // Tree
      re = -1.940157343d;
      im = 8e-7;
      iteration = 100;
      zoom = 319746448;
      break;
    case 7: // Flower
      re = -1.999985882d;
      im = 0;
      iteration = 244;
      zoom = 110654848544d;
      break;
    case 8: // Matei 1    
      re = 0.250488806d;
      im = 0.000073162d;
      iteration = 244;
      zoom = 814637;
      break;
    case 9: // Matei 2
      re = -0.481987673d;
      im = -0.532158033;
      iteration =1000;
      zoom = 41793;
      break;
    }

    // centrerer modellen omkring punktet, som brugeren har valgt
    currentPoint = new Complex(re, im);
    double modelWidth = 720.0d / (double)zoom;
    double modelHeight = 720.0d / (double)zoom;
    
    // modellen bliver opdateret
    modelLeft = re - modelWidth / 2;
    modelRight = re + modelWidth / 2;
    modelTop = im + modelHeight / 2;
    modelBottom = im - modelHeight / 2;
    // itereationSlideren bliver også opdateret
    iterationSlider.setValue(iteration);
  }
}
