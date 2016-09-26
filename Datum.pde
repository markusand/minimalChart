public class Datum {
    
    public int x;
    public float y;
    public String label;
    
    Datum(int y, String label) {
        this(0, y, label);
    }
    
    Datum(int x, float y) {
        this(x, y, null);
    }
    
    Datum(int x, float y, String label) {
        this.x = x;
        this.y = y;
        this.label = label;
    }
   
    public String toString() {
        return "DATUM: { x: " + x + ", y: " + y + ", label: " + label + " }";
    }
    
}