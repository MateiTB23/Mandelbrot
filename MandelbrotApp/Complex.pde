// klasse der modellerer et compleks tal
class Complex {
  private double re; // the real part
  private double im; // the imaginary part
  
  public Complex(double re, double im) {
    this.re = re;
    this.im = im;
  }

  public double getRe() {
    return this.re;
  }

  public double getIm() {
    return this.im;
  }
}
