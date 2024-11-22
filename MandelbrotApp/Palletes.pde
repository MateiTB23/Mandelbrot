// interface for alle paletter i MandelbrotAppen
public interface IPalette {
  int getSize(); // størrelse af paletten
  color[] getColors(); // farverne
}

// Palette0 modellerer en palette som dækker over syv farver
// og deres gradienter
public class Palette0 implements IPalette {
    
  private int totalSteps = 256; // Samlet antal farveovergange
  private color[] colors = new color[totalSteps]; // farverne
  int[] stepsPerTransition = {43, 42, 43, 42, 43, 43}; // man kan ikke dividere 256 til 6, så man blev nødt til have ulige sets 
  
  Palette0() {
    colors = new color[256];
     
    // overgang fra sort til gul til rød til magenta til blå til cyan til sort
    int idx = 0;
  
    // sort til gul (rød: 0 -> 255, grøn: 0 -> 255, blå: 0)
    for (int i = 0; i < 43; i++) {
      float t = i / 42.0;
      colors[idx++] = color(int(255 * t), int(255 * t), 0);
    }
  
    // gul til rød (rød: 255, grøn: 255 -> 0, blå: 0)
    for (int i = 0; i < 42; i++) {
      float t = i / 41.0;
      colors[idx++] = color(255, int(255 * (1 - t)), 0);
    }
  
    // rød til magenta (rød: 255, grøn: 0, blå: 0 -> 255)
    for (int i = 0; i < 43; i++) {
      float t = i / 42.0;
      colors[idx++] = color(255, 0, int(255 * t));
    }
  
    // magenta til blå (rød: 255 -> 0, grøn: 0, blå: 255)
    for (int i = 0; i < 42; i++) {
      float t = i / 41.0;
      colors[idx++] = color(int(255 * (1 - t)), 0, 255);
    }
  
    // blå til cyan (rød: 0, grøn: 0 -> 255, blå: 255)
    for (int i = 0; i < 43; i++) {
      float t = i / 42.0;
      colors[idx++] = color(0, int(255 * t), 255);
    }
  
    // cyan til sort (rød: 0, grøn: 255 -> 0, blå: 255 -> 0)
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

// Palette1 er insipireret af Ultra Fractal (håber på linket duer
// https://www.ultrafractal.com/help/index.html?/help/coloring/coloringsettings.html)
public class Palette1 implements IPalette {  
  private int totalSteps = 256; // Samlet antal farveovergange
  private color[] colors = new color[totalSteps];

  public Palette1() {
      
    // Definer de 16 basisfarver
    color[] baseColors = {
      color(66, 30, 15),    // Mørk brun
      color(25, 7, 26),     // Mørk lilla
      color(9, 1, 47),      // Mørk blå
      color(4, 4, 73),      // Medium blå
      color(0, 7, 100),     // Blå
      color(12, 44, 138),   // Lys blå
      color(24, 82, 177),   // Lys blå med grøn tone
      color(57, 125, 209),  // Himmelblå
      color(134, 181, 229), // Lys himmelblå
      color(211, 236, 248), // Lys cyan
      color(241, 233, 191), // Creme
      color(248, 201, 95),  // Lys orange
      color(255, 170, 0),   // Orange
      color(204, 128, 0),   // Mørk orange
      color(153, 87, 0),    // Mørk brun-orange
      color(106, 52, 3)     // Mørk brun
    };
    
    // Udfyld paletten med 256 farver ved at gentage de 16 basisfarver
    for (int i = 0; i < 256; i++) {
      colors[i] = baseColors[i % 16]; // Gå igennem de 16 basisfarver i cyklus
    }
  }
 
  public int getSize() {    
    return this.totalSteps;
  }
  
  public color[] getColors() {
    return this.colors;
  }
}

// Palette2 er en almindelig grayscale
public class Palette2 implements IPalette {  
  private int totalSteps = 256; // Antal gråtonetrin
  private color[] colors = new color[totalSteps];

  public Palette2() {
    // Generere gråtone farver
    for (int i = 0; i < totalSteps; i++) {
      // Brug en power-funktion til at bias mod lysere nuancer
      int intensity = (int)(255 * Math.sqrt((float)i / (totalSteps - 1))); // Skæv mod hvid
      colors[i] = color(intensity, intensity, intensity); // Gråtone farve
    }
  }
 
  public int getSize() {    
    return this.totalSteps;
  }
  
  public color[] getColors() {
    return this.colors;
  }
}

// Palette3 har en mere psykedelisk karakter
public class Palette3 implements IPalette {  
  private int totalSteps = 256;
  private color[] colors = new color[totalSteps];

  public Palette3() {
    for (int i = 0; i < totalSteps; i++) {
      if(i % 2 == 0)
        colors[i] = color(0, 0, 255); // blåt
      else
        colors[i] = color(255, 0, 0); // rødt
    }
  }
 
  public int getSize() {    
    return this.totalSteps;
  }
  
  public color[] getColors() {
    return this.colors;
  }
}
