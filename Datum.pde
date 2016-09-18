public class Datum {
    
    private int x;
    private float y;
    private String label;
    
    Datum(int x, float y) {
        this(x, y, null);
    }
    
    Datum(int x, float y, String label) {
        this.x = x;
        this.y = y;
        this.label = label;
    }
    
    public void setLabel(String label) {
        this.label = label;
    }
    
    
    public int getX() {
        return x;
    }
    
    public float getY() {
        return y;
    }
    
    public String getLabel() {
        return label;
    }
    
    public String toString() {
        return "DATUM: { x: " + x + ", y: " + y + ", label: " + label + " }";
    }
    
}