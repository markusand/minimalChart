/**
* Represent the minimum data type used in chart
* @author       Marc Vilella
*/
public class Datum {
    
    public int x;
    public float y;
    public final String LABEL;
    

    /**
    * Create a new datum without specifying an x value, used
    * mainly for pie and donut charts
    * @param y        the datum y value
    * @param label    the datum label
    */
    Datum(int y, String label) {
        this(0, y, label);
    }


    /**
    * Create a new datum without specifying a label
    * @param x    the x value
    * @param y    the y value
    */

    Datum(int x, float y) {
        this(x, y, null);
    }


    /**
    * Create a new datum
    * @param x        the x value
    * @param y        the y value
    * @param label    the datum label
    */
    Datum(int x, float y, String label) {
        this.x = x;
        this.y = y;
        LABEL = label;
    }
    
    
    @Override
    public String toString() {
        return "datum: { x: " + x + ", y: " + y + ", label: " + LABEL + " }";
    }
    
}