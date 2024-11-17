public interface IPalette {
  int getSize();
  color[] getColors();
}

public class Palette0 implements IPalette {
    
  private int totalSteps = 256; // Total number of color transitions
  private color[] colors = new color[totalSteps];
  int[] stepsPerTransition = {43, 42, 43, 42, 43, 43};
  
  Palette0() {
    colors = new color[256];
    
    // Transition from black to yellow to red to magenta to blue to cyan to black
    int idx = 0;
  
    // Black to Yellow (R: 0 -> 255, G: 0 -> 255, B: 0)
    for (int i = 0; i < 43; i++) {
      float t = i / 42.0;
      colors[idx++] = color(int(255 * t), int(255 * t), 0);
    }
  
    // Yellow to Red (R: 255, G: 255 -> 0, B: 0)
    for (int i = 0; i < 42; i++) {
      float t = i / 41.0;
      colors[idx++] = color(255, int(255 * (1 - t)), 0);
    }
  
    // Red to Magenta (R: 255, G: 0, B: 0 -> 255)
    for (int i = 0; i < 43; i++) {
      float t = i / 42.0;
      colors[idx++] = color(255, 0, int(255 * t));
    }
  
    // Magenta to Blue (R: 255 -> 0, G: 0, B: 255)
    for (int i = 0; i < 42; i++) {
      float t = i / 41.0;
      colors[idx++] = color(int(255 * (1 - t)), 0, 255);
    }
  
    // Blue to Cyan (R: 0, G: 0 -> 255, B: 255)
    for (int i = 0; i < 43; i++) {
      float t = i / 42.0;
      colors[idx++] = color(0, int(255 * t), 255);
    }
  
    // Cyan to Black (R: 0, G: 255 -> 0, B: 255 -> 0)
    for (int i = 0; i < 43; i++) {
      float t = i / 42.0;
      colors[idx++] = color(0, int(255 * (1 - t)), int(255 * (1 - t)));
    }
  }
 
  int getSize() {    
    return this.totalSteps;
  }
  
  color[] getColors() {
    return this.colors;
  }
}

public class Palette1 implements IPalette {  
  private int totalSteps = 256; // Total number of color transitions
  private color[] colors = new color[totalSteps];

  public Palette1() {
      
    // Define the 16 base colors
    color[] baseColors = {
      color(66, 30, 15),    // Dark brown
      color(25, 7, 26),     // Dark purple
      color(9, 1, 47),      // Dark blue
      color(4, 4, 73),      // Medium blue
      color(0, 7, 100),     // Blue
      color(12, 44, 138),   // Light blue
      color(24, 82, 177),   // Light blue with green tint
      color(57, 125, 209),  // Sky blue
      color(134, 181, 229), // Light sky blue
      color(211, 236, 248), // Light cyan
      color(241, 233, 191), // Cream
      color(248, 201, 95),  // Light orange
      color(255, 170, 0),   // Orange
      color(204, 128, 0),   // Dark orange
      color(153, 87, 0),    // Dark brown-orange
      color(106, 52, 3)     // Dark brown
    };
    
    // Fill the 256-color palette by repeating the 16 base colors
    for (int i = 0; i < 256; i++) {
      colors[i] = baseColors[i % 16]; // Cycle through the 16 base colors
    }
  }
 
  public int getSize() {    
    return this.totalSteps;
  }
  
  public color[] getColors() {
    return this.colors;
  }
}

public class Palette2 implements IPalette {  
  private int totalSteps = 256; // Total number of grayscale steps
  private color[] colors = new color[totalSteps];

  public Palette2() {
    // Generate the grayscale colors
    for (int i = 0; i < totalSteps; i++) {
      // Use a power function to bias towards lighter shades
      int intensity = (int)(255 * Math.sqrt((float)i / (totalSteps - 1))); // Skew towards white
      colors[i] = color(intensity, intensity, intensity); // Grayscale color
    }
  }
 
  public int getSize() {    
    return this.totalSteps;
  }
  
  public color[] getColors() {
    return this.colors;
  }
}


public class Palette3 implements IPalette {  
  private int totalSteps = 256; // Total number of grayscale steps
  private color[] colors = new color[totalSteps];

  public Palette3() {
    // Generate the grayscale colors
    for (int i = 0; i < totalSteps; i++) {
      if(i % 2 == 0)
        colors[i] = color(0, 0, 255);
      else
        colors[i] = color(255, 0, 0);
    }
  }
 
  public int getSize() {    
    return this.totalSteps;
  }
  
  public color[] getColors() {
    return this.colors;
  }
}
