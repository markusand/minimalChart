import java.util.Map.Entry;

/**
* Represents a chart and allows to plot different data sets. This is an abstract class with basic chart
* functionality, different types of chart can be instantiated with specific subclasses (e.g LineChart).
* @author       Marc Vilella
*/
public abstract class Chart {

    public final PVector TL;
    public final PVector SIZE;
    protected PVector limitsMin;
    protected PVector limitsMax;
    
    protected int margin = 0;
    
    protected boolean showAxisX = false;
    protected boolean showAxisY = false;
    protected int decimals = 0;
    
    protected boolean stacked = false;
    
    protected ArrayList<DataSet> sets = new ArrayList();  
    protected HashMap<Integer, String> labels = new HashMap();
    protected Datum minY = null;
    protected Datum maxY = null;
    protected Datum minX = null;
    protected Datum maxX = null;
    
    protected ArrayList<Tooltip> tooltips = new ArrayList();
    protected ArrayList<Threshold> thresholds = new ArrayList();
    
    
    /**
    * Create a new chart in specified position with specified size
    * @param TLx       the x position of Top-Left corner
    * @param TLy       the y position of Top-Left corner
    * @param width     the width of chart
    * @param height    the height of chart
    */
    public Chart(int TLx, int TLy, int width, int height) {
        TL = new PVector(TLx, TLy);
        SIZE = new PVector(width, height);
    }
    
    
    /**
    * Set the number of decimals to display
    * @param decimals    the number of decimals
    * @return            the chart itself, simply used for method chaining
    */
    public Chart setDecimals(int decimals) {
        this.decimals = decimals;
        return this;
    }
    
    
    /**
    * Set whether the chart is stacked
    * @param stacked    whether the chart is stacked 
    * @return           the chart itself, simply used for method chaining
    */
    public Chart stacked(boolean stacked) {
        this.stacked = stacked;
        return this;
    }
    
    
    /**
    * Set whether the horizontal (x) and vertical (y) axis are shown
    * @param axisX    whether the x axis is shown
    * @param axisY    whether the y axis is shown
    * @return         the chart itself, simply used for method chaining
    */
    public Chart showAxis(boolean axisX, boolean axisY) {
        showAxisX = axisX;
        showAxisY = axisY;
        if(showAxisX) limitsMin.sub(0, 15);  // Padding for labels
        else limitsMin.y = SIZE.y;
        return this;
    }
    
    
    /**
    * Add a threshold to the chart
    * @param threshold    the threshold to add
    */
    public void addThreshold(Threshold threshold) {
        thresholds.add( threshold );
    }
    
    
    /**
    * Clear the chart. Delete all existing datasets and initiate boundaries
    */
    public void clear() {
        sets.clear();
        minX = maxX = minY = maxY = null;
        labels = new HashMap();
    }
    
    
    /**
    * Add dataset(s) to chart. after one dataset is added, min and max boundaries are recalculated
    * @param sets    the set(s) to add
    */
    public void add(DataSet... newSets) {
        for(DataSet set : newSets) {
            if( !set.isEmpty() ) {
                sets.add(set);
                if( !stacked ) {
                    if( minY == null || set.min().y < minY.y ) minY = set.min();
                    if( maxY == null || set.max().y > maxY.y ) maxY = set.max();
                }
                if( minX == null || set.first().x < minX.x ) minX = set.first();
                if( maxX == null || set.last().x > maxX.x ) maxX = set.last();
                
                for(Entry l : set.getLabels().entrySet()) {
                    int x = (int) l.getKey();
                    String label = (String) l.getValue();
                    if( !labels.containsKey(x) ) labels.put(x, label);
                    else if( !labels.get(x).equals(label) ) labels.put(x, labels.get(x) + "\n" + label); 
                }
                
            }
        }
        if(stacked) calcStackedBounds();
    }
    
    
    /**
    * Calculate min and max boundaries for stacked chart, and largest number of sample
    */
    protected void calcStackedBounds() {
        if( maxX == null || minX == null) return;
        float[] stack = new float[ maxX.x - minX.x + 1 ];
        for(DataSet set : sets) {
            for(Datum datum : set.data()) {
                stack[ datum.x - minX.x ] += datum.y;
            }
        }
        minY = new Datum(0, 0, "MIN" );
        for(int i = 0; i < stack.length; i++) {
            if( maxY == null || stack[i] > maxY.y ) maxY = new Datum( minX.x + i, stack[i], "MAX" );
        }
    }
    
    
    /**
    * Draw the chart
    */
    public void draw() {
        if( sets.size() > 0 ) { 
        
            //hint(DISABLE_OPTIMIZED_STROKE);
            
            FloatList stack = new FloatList();
            tooltips = new ArrayList();
            
            pushStyle();
            pushMatrix();
            translate(TL.x, TL.y);
            
            drawAxis();
            
            for(int i = 0; i < sets.size(); i++) {
                drawDataSet(i, sets.get(i), stack);
                if(stacked) stack = updateStack(stack, sets.get(i));
            }
            
            for(Tooltip tooltip : tooltips) tooltip.draw();
            
            popMatrix();
            popStyle();
            
            for(Threshold threshold : thresholds) threshold.draw(this);
            
        }
    }
    
    
    /**
    * Get the position of XY value in chart
    * @param x    the x value
    * @param y    the y value
    * @return     the position in chart
    */
    public PVector getPosition(int x, float y) {
        return new PVector(
            map(x, minX.x, maxX.x, limitsMin.x, limitsMax.x),
            map(y, minY.y, maxY.y, limitsMin.y, limitsMax.y)
        );
    } 
    
    
    /**
    * Update stack adding actual dataset values to it
    * @param stack    the stack
    * @param set      the actual dataset
    * @return         the updated stack
    */
    private FloatList updateStack(FloatList stack, DataSet set) {
        for(Datum d : set.data()) {
            while( stack.size() <= d.x ) stack.append(minY.y);  // Add (possible) missing values
            stack.add(d.x, d.y);
        }
        return stack;
    }
    
    
    /**
    * Draw chart axis if required
    */
    protected abstract void drawAxis();
    
    
    /**
    * Draw a dataset
    * @param setNum    the order number of dataset
    * @param set       the set to draw
    * @param stack     the stack. If the chart is not stacked, stack will be full of minims
    */
    protected abstract void drawDataSet(int setNum, DataSet set, FloatList stack);
         
    
    /**
    * Return whether a point is inside chart boundaries
    * @param point    Point to check
    * @return         true if point is inside chart, false otherwise
    */
    protected boolean inChart(PVector point) {
        return point.x >= 0 && point.x <= SIZE.x && point.y >= 0 && point.y <= SIZE.y;
    }
    
    
    /**
    * Get the mouse position over the chart. Position is relative to chart origin, and trnaslation is corrected
    * @return    the mouse position
    */
    protected PVector mousePos() {
        return new PVector(mouseX, mouseY).sub(TL.x, TL.y);
    }
    
    
    /**
    * Check whether a point is close to a reference point. Closeness is defined by a deviation in two axis (x and y)
    * @param point    the point to check
    * @param ref      the reference point
    * @param dx       the deviation in x-axis
    * @param dy       the deviation in y-axis
    * @return         true if point is close, false otherwise
    */
    protected boolean isClose(PVector point, PVector ref, float dx, float dy) {
        if( !inChart(point) ) return false;
        return abs( point.x - ref.x ) <= dx && abs( point.y - ref.y ) <= dy;
    }
    
    
    /**
    * Draw a dot with specified color and size
    * @param pos     the position of dot
    * @param tint    the color of dot
    * @param size    the size of dot
    */
    protected void drawDot(PVector pos, color tint, int size) {
        drawDot(pos.x, pos.y, tint, size);
    }
    
    
    /**
    * Draw a dot with specified color and size
    * @param x       the horizontal position
    * @param y       the vertical position
    * @param tint    the color of dot
    * @param size    the size of dot
    */
    protected void drawDot(float x, float y, color tint, int size) {
        fill(tint); noStroke();
        ellipse(x, y, size, size);
    }     
    
    
    /**
    * Draw a line with specified color and stroke size
    * @param from      the initial point of line
    * @param to        the f-inal point of line
    * @param tint      the color of line
    * @param stroke    the stroke width of line
    */
    protected void drawLine(PVector from, PVector to, color tint, int stroke) {
        noFill(); stroke(tint); strokeWeight(stroke);
        line(from.x, from.y, to.x, to.y);
    }     
    
    
    /**
    * Draw an area with specified color
    * @param v1, v2, v3, v4    the vertices of area
    * @param tint              the color of area
    */
    protected void drawArea(PVector v1, PVector v2, PVector v3, PVector v4, color tint) {
        fill(tint); noStroke();
        noStroke();
        beginShape();
            //fill( lerpColor(color(#00FF00,70), tint, v1.y / size.y) );
            vertex(v1.x, v1.y);
            //fill( lerpColor(color(#00FF00,70), tint, v2.y / size.y) );
            vertex(v2.x, v2.y);
            //fill( lerpColor(color(#00FF00,70), tint, v3.y / size.y) );
            vertex(v3.x, v3.y);
            //fill( lerpColor(color(#00FF00,70), tint, v4.y / size.y) );
            vertex(v4.x, v4.y);
        endShape(CLOSE);
    }
         
}