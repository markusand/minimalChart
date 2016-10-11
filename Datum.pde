public class Datum {
    
    public final int x;
    public final float y;
    public final String LABEL;
    
    Datum(int y, String label) {
        this(0, y, label);
    }
    
    Datum(int x, float y) {
        this(x, y, null);
    }
    
    Datum(int x, float y, String label) {
        this.x = x;
        this.y = y;
        LABEL = label;
    }
   
    public String toString() {
        return "datum: { x: " + x + ", y: " + y + ", label: " + LABEL + " }";
    }
    
}