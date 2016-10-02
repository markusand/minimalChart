/*
 * minimalChart
 * 
 * Draw simple and minimalistic charts
 *
 * @author          Marc Vilella
 *                  Observatori de la Sostenibilitat d'Andorra (OBSA)
 *                  mvilella@obsa.ad
 * @contributors    
 * @copyright       Copyright (c) 2016 Marc Vilella
 * @license         MIT License
 * @required        
 * @version         0.1
 *
 * @bugs            RADAR charts do not close and have not proper hover tooltips
 *
 * @todo            Add BAR and PIE charts
*/


import java.util.Map.Entry;


public abstract class Chart {

    protected PVector TL;
    protected PVector size;
    protected PVector plotMin;
    protected PVector plotMax;
    
    protected int margin = 0;
    
    protected boolean showAxisX = false;
    protected boolean showAxisY = false;
    protected int decimals = 0;
    
    protected boolean stacked = false;
    
    protected ArrayList<Set> sets = new ArrayList();  
    protected HashMap<Integer, String> labels = new HashMap();
    protected Datum minY = null;
    protected Datum maxY = null;
    protected Datum minX = null;
    protected Datum maxX = null;
    
    protected ArrayList<Tooltip> tooltips = new ArrayList();
    protected ArrayList<Threshold> thresholds = new ArrayList();
    
    
    // Constructor for chart
    // @param TLx  Position x of Top-Left corner
    // @param TLy  Position y of Top-Left corner
    // @param width  Width of chart
    // @param height  Height of chart
    public Chart(int TLx, int TLy, int width, int height) {
        TL = new PVector(TLx, TLy);
        size = new PVector(width, height);
    }
    
    
    // Set de number of decimals to display
    // @param dec  Number of decimals
    public Chart setDecimals(int decimals) {
        this.decimals = decimals;
        return this;
    }
    
    
    // Set graph with stacked datasets
    // @param stacked
    public Chart stacked(boolean stacked) {
        this.stacked = stacked;
        return this;
    }
    
    
    // Set visibility of axis
    // @param axisX  Vertical axis
    // @param axisY  Horizontal axis
    public Chart showAxis(boolean axisX, boolean axisY) {
        showAxisX = axisX;
        showAxisY = axisY;
        // Padding for labels
        if(showAxisX) plotMin.y -= 15;
        else plotMin.y = size.y;
        return this;
    }
    
    
    // Add a threshold line in chart
    // @param name  Name of the threshold
    // @param value  Value to set the threshold
    // @param tint  Color of threshold line
    public void addThreshold(String name, float value, color tint) {
        addThreshold(name, value, value, tint);
    }
    
    
    // Add a threshold area in chart
    // @param name  Name of the threshold
    // @param min  Minimum value of threshold area
    // @param max  Maximum value of threshold area
    // @param tint  Color of threshold area
    public void addThreshold(String name, float min, float max, color tint) {
        thresholds.add( new Threshold(this, name, min, max, tint) );
    }
    
    
    // Set the chart to an initial "blank" state. Delete all existing datasets and initiate boundaries
    public void clear() {
        sets.clear();
        minX = maxX = minY = maxY = null;
        labels = new HashMap();
    }
    
    
    // Add a dataset to chart, and update boundaries
    // @param sets  Set(s) to add to chart
    public void add(Set... newSets) {
        for(Set set : newSets) {
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
    
    
    // Calculate min and max boundaries for stacked chart, and largest number of sample
    protected void calcStackedBounds() {
        if( maxX == null || minX == null) return;
        float[] stack = new float[ maxX.x - minX.x + 1 ];
        for(Set set : sets) {
            for(Datum datum : set.data()) {
                stack[ datum.x - minX.x ] += datum.y;
            }
        }
        minY = new Datum(0, 0, "MIN" );
        for(int i = 0; i < stack.length; i++) {
            if( maxY == null || stack[i] > maxY.y ) maxY = new Datum( i + minX.x, stack[i], "MAX" );
        }
    }
    
    
    // Draw Chart
    public void draw() {
        
        if(minX == null || maxX == null || minY == null || maxY == null) return;
        if(minX.x >= maxX.x || minY.y >= maxY.y) return;
        
        FloatList stack = new FloatList();
        tooltips = new ArrayList();
        
        pushStyle();
        pushMatrix();
        translate(TL.x, TL.y);
        
        drawAxis(showAxisX, showAxisY);
        
        for(Set set : sets) {
            drawSet(stack, set);
            if(stacked) stack = updateStack(stack, set);
        }
        
        for(Threshold threshold : thresholds) threshold.draw();
        for(Tooltip tooltip : tooltips) tooltip.draw();
        
        popMatrix();
        popStyle();
    }
    
    
    // Get position in chart of value
    // @param x  x value
    // @param y  y value
    protected PVector getPosition(int x, float y) {
        return new PVector(
            map(x, minX.x, maxX.x, plotMin.x, plotMax.x),
            map(y, minY.y, maxY.y, plotMin.y, plotMax.y)
        );
    } 
    
    
    // Update stack container
    // @param stack  List with stacked values
    // @param set  Set with values to add
    // @return updated stack with added set values
    private FloatList updateStack(FloatList stack, Set set) {
        for(Datum d : set.data()) {
            while( stack.size() <= d.x ) stack.append( minY.y );
            stack.add(d.x, d.y);
        }
        return stack;
    }
    
    
    // Draw axis if required
    // @param x  Draw x axis if true
    // @param y  Draw y axis if true
    protected abstract void drawAxis(boolean x, boolean y);
    
    
    // Draw set
    // @param stack  List with stacked values (if available)
    // @param set  Set to draw
    protected abstract void drawSet(FloatList stack, Set set);
         
    
    // Check if point is inside chart boundaries
    // @param point  Point to check
    // @return true is point is inside chart, false otherwise
    protected boolean inChart(PVector point) {
        return point.x >= 0 && point.x <= size.x && point.y >= 0 && point.y <= size.y;
    }
    
    
    // Get mouse position over chart (correcting translate)
    // @return x,y position of mouse
    protected PVector mousePos() {
        return new PVector(mouseX, mouseY).sub(TL.x, TL.y);
    }
    
    
    // Check if a point is inbetween a deviation from a reference point
    // @param point  Point to check
    // @param ref  Reference point to check
    // @param dx  Deviation in x-axis
    // @param dy  Deviation in y-axis
    // @return true if point is inbetween, false if not
    protected boolean isClose(PVector point, PVector ref, float dx, float dy) {
        if( !inChart(point) ) return false;
        return abs( point.x - ref.x ) <= dx && abs( point.y - ref.y ) <= dy;
    }
    
    
    
    protected void drawDot(PVector pos, color tint, int size) { drawDot(pos.x, pos.y, tint, size); }
    protected void drawDot(float x, float y, color tint, int size) {
        fill(tint); noStroke();
        ellipse(x, y, size, size);
    }     
         
    protected void drawLine(PVector from, PVector to, color tint, int weight) {
        noFill(); stroke(tint); strokeWeight(weight);
        line(from.x, from.y, to.x, to.y);
    }     
    
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