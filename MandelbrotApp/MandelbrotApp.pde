import controlP5.*; // Importer ControlP5 library for GUI controls som buttons and sliders
private ControlP5 cp5;
private Slider iterationSlider;
private JuliaSetCanvas juliaSetCanvas;
private MandelbrotSetCanvas mandelbrotSetCanvas;
private CurrentPointTooltipCanvas currentPointTooltipCanvas;
private DropdownList paletteDropdownList;
private DropdownList jumpToDropdownList; 
private IPalette palette0 = new Palette0();
private IPalette palette1 = new Palette1();
private IPalette palette2 = new Palette2();
private IPalette currentPalette = palette0;
private Complex currentPoint;
private double model_left;
private double model_right;
private double model_top;
private double model_bottom;
private double model_left_original = -3d;
private double model_right_original = +3d;
private double model_top_original = +3d;
private double model_bottom_original = -3d;
private double zoomFactor = 1.05d;
private double scaleX = 1.0d;
private double scaleY = 1.0d;
boolean drawAxes = false;
boolean drawGrid = false;
boolean drawIterations = false;

void setup() {
  resetModel();

  int window_width = 1280;
  int window_height = 720;
  int delta = window_width-window_height;
  int juliaSetCanvasWidth = delta;
  int juliaSetCanvasHeight = delta;
  int mandelbrotSetCanvasWidth = window_height;
  int mandelbrotSetCanvasHeight = window_height;
  int widgetWidth = 200;
  int widgetHeight = 25;
  int widgetMargin = 10;

  size(1280, 720);
  cp5 = new ControlP5(this);

  juliaSetCanvas = new JuliaSetCanvas();
  juliaSetCanvas.setPosition(mandelbrotSetCanvasWidth, 0);
  juliaSetCanvas.setSize(juliaSetCanvasWidth, juliaSetCanvasHeight);
  juliaSetCanvas.setPalette(currentPalette);

  mandelbrotSetCanvas = new MandelbrotSetCanvas(juliaSetCanvas);
  mandelbrotSetCanvas.setPosition(0, 0);
  mandelbrotSetCanvas.setSize(mandelbrotSetCanvasWidth, mandelbrotSetCanvasHeight);
  mandelbrotSetCanvas.setPalette(currentPalette);

  currentPointTooltipCanvas = new CurrentPointTooltipCanvas();


  cp5.addCanvas(mandelbrotSetCanvas);
  cp5.addCanvas(juliaSetCanvas);
  cp5.addCanvas(currentPointTooltipCanvas);

  // Create the iteration slider
  iterationSlider = cp5.addSlider("Iterations")
    .setRange(0, this.currentPalette.getSize() * 4)
    .setValue(20)
    .setPosition(mandelbrotSetCanvasWidth, juliaSetCanvasHeight)
    .setSize(widgetWidth, widgetHeight)
    .setNumberOfTickMarks(this.currentPalette.getSize())
    .showTickMarks(true)
    .snapToTickMarks(true);

  // Create a button to reset the model
  cp5.addButton("reset") // Button name (also used as a callback method)
    .setPosition(mandelbrotSetCanvasWidth, juliaSetCanvasHeight + widgetHeight + widgetMargin) // Position (x, y)
    .setSize(widgetWidth / 2 - 5, widgetHeight) // Size (width, height)
    .setLabel("Reset the model") // Button label
    .getCaptionLabel() // Access the label settings
    .align(ControlP5.CENTER, ControlP5.CENTER); // Align label to the center, centered vertically

  // Create a toggle enable disable the drawing of grid
  cp5.addToggle("drawGrid") // Toggle name (also used as a callback)
    .setPosition(mandelbrotSetCanvasWidth + widgetWidth / 2 + 5, juliaSetCanvasHeight + widgetHeight + widgetMargin) // Position on canvas
    .setSize(widgetWidth / 2 - 5, widgetHeight) // Width and height
    .setValue(false) // Initial state (false = off)
    .setLabel("Draw Grid") // Label displayed on the toggle
    .getCaptionLabel() // Access the label settings
    .align(ControlP5.CENTER, ControlP5.CENTER); // Align label to the center, centered vertically

  // Create a toggle enable disable the drawing of axes
  cp5.addToggle("drawAxes") // Toggle name (also used as a callback)
    .setPosition(mandelbrotSetCanvasWidth, juliaSetCanvasHeight + 2 * (widgetHeight + widgetMargin)) // Position on canvas
    .setSize(widgetWidth / 2 - 5, widgetHeight) // Width and height
    .setValue(false) // Initial state (false = off)
    .setLabel("Draw Axes") // Label displayed on the toggle
    .getCaptionLabel() // Access the label settings
    .align(ControlP5.CENTER, ControlP5.CENTER); // Align label to the center, centered vertically

  // Create a toggle enable disable the drawing of iterations
  cp5.addToggle("drawIterations") // Toggle name (also used as a callback)
    .setPosition(mandelbrotSetCanvasWidth + widgetWidth / 2 + 5, juliaSetCanvasHeight + 2 * (widgetHeight + widgetMargin)) // Position on canvas
    .setSize(widgetWidth / 2 - 5, widgetHeight) // Width and height
    .setValue(false) // Initial state (false = off)
    .setLabel("Draw Iterations") // Label displayed on the toggle
    .getCaptionLabel() // Access the label settings
    .align(ControlP5.CENTER, ControlP5.CENTER); // Align label to the center, centered vertically

  paletteDropdownList = cp5.addDropdownList("paletteDropdownList")
    .setPosition(mandelbrotSetCanvasWidth, juliaSetCanvasHeight + 3 * (widgetHeight + widgetMargin))
    .setSize(widgetWidth, widgetHeight * 3)
    .setLabel("Select Palette")
    .addItem("Palette 1 (7 colors)", 0)
    .addItem("Palette 2 (Ultra Fractal)", 1)
    .addItem("Palette 3 (Grayscale)", 2)
    .setValue(0);
    
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

// Callback for the toggle button to enbable/disable draw axes
void drawAxes(boolean state) {
  drawAxes = state; // Update state based on toggle
}

// Callback for the toggle button to enbable/disable draw grid
void drawGrid(boolean state) {
  drawGrid = state; // Update state based on toggle
}

// Callback for the toggle button to enbable/disable draw iterations
void drawIterations(boolean state) {
  drawIterations = state; // Update state based on toggle
}

private void resetModel() {
  this.model_left = model_left_original;
  this.model_right = model_right_original;
  this.model_top = model_top_original;
  this.model_bottom = model_bottom_original;
  this.zoomFactor = 1.05f;
  if (this.iterationSlider != null)
    this.iterationSlider.setValue(20f);
}

void mousePressed() {
  mandelbrotSetCanvas.mousePressed();
}

void mouseReleased() {
  mandelbrotSetCanvas.mouseReleased();
}

void mouseDragged() {
  mandelbrotSetCanvas.mouseDragged();
}

void mouseWheel(MouseEvent event) {
  mandelbrotSetCanvas.mouseWheel(event);
}

void controlEvent(ControlEvent event)
{
  if (event.isFrom(paletteDropdownList))
  {
    //int selection = paletteDropdownList.getItem((int) event.getValue());
    switch ((int) event.getValue()) {
    case 0:
      currentPalette = palette0;
      break;
    case 1:
      currentPalette = palette1;
      break;
    case 2:
      currentPalette = palette2;
      break;
    }
    mandelbrotSetCanvas.setPalette(currentPalette);
    juliaSetCanvas.setPalette(currentPalette);
  }
  
  if (event.isFrom(jumpToDropdownList))
  {
    double re = 0.0d;
    double im = 0.0d;
    int iteration = 1;
    double zoom = 100;
      
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
    
    currentPoint = new Complex(re, im);
    double model_width = 720.0d / (double)zoom;
    double model_height = 720.0d / (double)zoom;
    model_left = re - model_width / 2;
    model_right = re + model_width / 2;
    model_top = im + model_height / 2;
    model_bottom = im - model_height / 2;
    iterationSlider.setValue(iteration);
    
    //println("(" + model_left + ", " + model_right + ", " + model_bottom + ", " + model_top + ")");
  }
}
