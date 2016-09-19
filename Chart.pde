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


public abstract class Chart {

    protected PVector TL;
    protected PVector size;
    
    protected int margin = 0;
    
    protected boolean showAxisX = false;
    protected boolean showAxisY = false;
    protected int decimals = 0;
    
    protected boolean stacked = false;
    
    protected ArrayList<Set> sets = new ArrayList();   
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
    public void setDecimals(int decimals) {
        this.decimals = decimals;
    }
    
    
    // Set graph with stacked datasets
    // @param stacked
    public void stacked(boolean stacked) {
        this.stacked = stacked;
    }
    
    
    // Set visibility of axis
    // @param axisX  Vertical axis
    // @param axisY  Horizontal axis
    public void showAxis(boolean axisX, boolean axisY) {
        showAxisX = axisX;
        showAxisY = axisY;
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
    }
    
    
    // Add a dataset to chart, and update boundaries
    // @param sets  Set(s) to add to chart
    public void add(Set... newSets) {
        for(Set set : newSets) {
            this.sets.add(set);
            if( !set.isEmpty() ) {
                if( !stacked ) {
                    if( minY == null || set.getMin().getY() < minY.getY() ) minY = set.getMin();
                    if( maxY == null || set.getMax().getY() > maxY.getY() ) maxY = set.getMax();
                }
                if( minX == null || set.getFirst().getX() < minX.getX() ) minX = set.get(0);
                if( maxX == null || set.getLast().getX() > maxX.getX() ) maxX = set.getLast();
            }
        }
        if( stacked ) calcStackedBounds();
    }
    
    
    // Calculate min and max boundaries for stacked chart, and largest number of sample
    private void calcStackedBounds() {
        float[] stack = new float[ maxX.getX() - minX.getX() + 1 ];
        for(Set set : sets) {
            for(Datum datum : set.getAll()) {
                stack[ datum.getX() - minX.getX() ] += datum.getY();
            }
        }
        minY = new Datum(0, 0, "MIN" );
        for(int i = 0; i < stack.length; i++) {
            if( maxY == null || stack[i] > maxY.getY() ) maxY = new Datum( i + minX.getX(), stack[i], "MAX" );
        }
    }
    
    
    // Draw Chart
    public void draw() {
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
            map(x, minX.getX(), maxX.getX(), 0, size.x),
            map(y, minY.getY(), maxY.getY(), size.y, 0)
        );
    } 
    
    
    // Update stack container
    // @param stack  List with stacked values
    // @param set  Set with values to add
    // @return updated stack with added set values
    private FloatList updateStack(FloatList stack, Set set) {
        for(Datum d : set.getAll()) {
            while( stack.size() <= d.getX() ) stack.append( minY.getY() );
            stack.add(d.getX(), d.getY());
        }
        return stack;
    }
    
    
    // Draw axis if required
    // @param x  Draw x axis if true
    // @param y  Draw y axis if true
    protected void drawAxis(boolean x, boolean y) {
        for(int i = minX.getX(); i <= maxX.getX(); i++) {
            PVector axisBottom = getPosition(i, minY.getY());
            PVector axisTop = getPosition(i, maxY.getY());
            drawLine(axisBottom, axisTop, #DDDDDD, 1);
        }
    }
    
    
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
    
    
    protected PVector mousePos() {
        return new PVector(mouseX, mouseY).sub(TL.x, TL.y);
    }
    
    protected boolean isClose(PVector point, PVector ref, float dx, float dy) {
        if( !inChart(point) ) return false;
        return abs( point.x - ref.x ) <= dx && abs( point.y - ref.y ) <= dy;
    }
    
    
    
         
         
    protected void drawDot(PVector pos, color tint, int size) {
        fill(tint); noStroke();
        ellipse(pos.x, pos.y, size, size);
    }     
         
    protected void drawLine(PVector from, PVector to, color tint, int weight) {
        noFill(); stroke(tint); strokeWeight(weight);
        line(from.x, from.y, to.x, to.y);
    }     
    
    protected void drawArea(PVector v1, PVector v2, PVector v3, PVector v4, color tint) {
        fill(tint); noStroke();
        beginShape();
            vertex(v1.x, v1.y);
            vertex(v2.x, v2.y);
            vertex(v3.x, v3.y);
            vertex(v4.x, v4.y);
        endShape(CLOSE);
    }
         
}




/*
public class RadarChart extends Chart {

    PVector center;
    float R;
    
    public RadarChart(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
        center = new PVector(TLx, TLy).add(width/2, height/2);
        R = min(BR.x - TL.x, BR.y - TL.y) / 2;
    }
    
    
    @Override
    protected void drawAxisX() {
        pushMatrix();
        translate(center.x, center.y);
        float angle = TWO_PI / samples;
        for(int i = 0; i < samples; i++) {
            noFill(); stroke(#DDDDDD); strokeWeight(1);
            line(0, 0, 0, -R);
            fill(#DDDDDD); textSize(9); textAlign(CENTER, CENTER);
            text(i, 0, -R - 10);
            rotate(angle);
        }
        popMatrix();
    }
    
    
    @Override
    protected void drawAxisY() {
        int divs = 5;
        pushMatrix();
        translate(center.x, center.y);
        for(int i = 0; i <= divs ; i++) {
            float y = lerp(0, R, (float) i / divs );
            noFill(); stroke(#DDDDDD); strokeWeight(1); ellipseMode(RADIUS);
            ellipse(0, 0, y, y);
            float value = map(y, 0, R, min, max);
            stroke(#DDDDDD); textSize(9); textAlign(LEFT, BOTTOM);
            text(String.format("%." + decimals + "f", value), 2, -y);
        }
        popMatrix();
    }
    
    
    @Override
    protected void drawAxis0() {
        pushMatrix();
        translate(center.x, center.y);
        float y0 = map(0, min, max, 0, R);
        stroke(#DDDDDD); strokeWeight(1); ellipseMode(RADIUS);
        ellipse(0, 0, y0, y0);
        textAlign(LEFT, BOTTOM); textSize(9);
        text(0, 2, -y0);
        popMatrix();
    }
    
    
    @Override
    protected PVector getPos(int i, float value) {
        return polar2cartesian(getPos(value), - HALF_PI + i * TWO_PI / samples).add(center);
    }
    
    
    @Override
    protected float getPos(float value) {
        return map(value, min, max, 0, R);
    }
    
    
    private PVector polar2cartesian(float R, float angle) {
        return new PVector( R * cos(angle), R * sin(angle) );
    }
    
    
    protected void drawPos(Set set, PVector prevPosStack, PVector posStack, PVector prevPos, PVector pos) {
        fill(set.tint, 50); noStroke();
        if(prevPos != null && prevPosStack != null) {
            
            
            beginShape();
            vertex(prevPosStack.x, prevPosStack.y);
            vertex(prevPos.x, prevPos.y);
            vertex(pos.x, pos.y);
            vertex(posStack.x, posStack.y);
            endShape();
            
            stroke(set.tint); strokeWeight(1);
            line(prevPos.x, prevPos.y, pos.x, pos.y);
        }
    }
    
}
*/