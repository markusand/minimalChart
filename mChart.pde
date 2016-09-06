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


public class Set {

    protected String name;
    protected String unit;
    protected color tint;
    
    private FloatList values = new FloatList();
    protected float min = Float.MAX_VALUE;
    protected float max = Float.MIN_VALUE;
    
    
    /*
    * Constructor for dataset
    * @param name Name of dataset
    * @param unit Unit for all values in dataset
    * @param tint Color of dataset
    */
    Set(String name, String unit, color tint) {
        this.name = name;
        this.unit = unit;
        this.tint = tint;
    }
    
    
    /*
    * Add new value in dataset, and update min/max boundaries
    * @param values Value(s) to add in dataset
    */
    public void add(float... values) {
        for(float value : values) {
            this.values.append(value);
            if(value < min) min = value;
            if(value > max) max = value;
        }
    }
    
    
    /*
    * Get value from dataset
    * @param i Index of value to get
    * @return value from dataset in index, or 0 if index is outside
    */
    public float value(int i) {
        if( i < values.size() ) return values.get(i);
        else return 0;
    }
    
    
    /*
    * Get the size of the dataset values array
    * @return size of dataset
    */
    public int size() {
        return values.size();
    }
    
    
}




public abstract class Chart {

    protected PVector TL;
    protected PVector BR;
    
    protected int margin;
    
    protected boolean showAxisX;
    protected boolean showAxisY;
    protected int decimals = 0;
    
    protected boolean stacked;
    
    protected ArrayList<Set> sets = new ArrayList<Set>();   
    protected float min = Float.MAX_VALUE;
    protected float max = Float.MIN_VALUE;
    protected int samples = 0;
    
    protected ArrayList<Threshold> thresholds = new ArrayList<Threshold>();
    
    
    /*
    * Constructor for chart
    * @param TLx x position of Top-Left corner
    * @param TLy y position of Top-Left corner
    * @param width Width of chart
    * @param height Height of chart
    */
    public Chart(int TLx, int TLy, int width, int height) {
        TL = new PVector(TLx, TLy);
        BR = new PVector(TLx + width, TLy + height);
    }
    
    
    /*
    * Set de number of decimals to display
    * @param dec Number of decimals
    */
    public void decimals(int decimals) {
        this.decimals = decimals;
    }
    
    
    /*
    * Set graph with stacked datasets
    * @param stacked 
    */
    public void stacked(boolean stacked) {
        this.stacked = stacked;
    }
    
    
    /*
    * Set visibility of axis
    * @param axisX Vertical axis
    * @param axisY Horizontal axis
    */
    public void showAxis(boolean axisX, boolean axisY) {
        showAxisX = axisX;
        showAxisY = axisY;
    }
    
    
    /*
    * Add a threshold line in chart
    * @param name Name of the threshold
    * @param value Value to set the threshold
    * @param tint Color of threshold line
    */
    public void threshold(String name, float value, color tint) {
        threshold(name, value, value, tint);
    }
    
    
    /*
    * Add a threshold area in chart
    * @param name Name of the threshold
    * @param min Minimum value of threshold area
    * @param max Maximum value of threshold area
    * @param tint Color of threshold area
    */
    public void threshold(String name, float min, float max, color tint) {
        thresholds.add( new Threshold(name, min, max, tint) );
    }
    
    
    /*
    * Set the chart to an initial "blank" state. Delete all existing
    * datasets and initiate boundaries
    */
    public void clear() {
        sets.clear();
        min = Float.MAX_VALUE;
        max = Float.MIN_VALUE;
        samples = 0;
    }
    
    
    /*
    * Add a dataset to chart, and update boundaries
    * @param sets Set(s) to add to chart
    */
    public void add(Set... sets) {
        for(Set set : sets) {
            this.sets.add(set);
        }
        if(stacked) calcStackedBounds();
        else calcBounds();
    }
    
    
    /*
    * Calculate min and max boundaries in chart, and largest number of samples
    */
    private void calcBounds() {
        for(Set set : sets) {
            if( set.min < min ) min = floor(set.min);
            if( set.max > max ) max = ceil(set.max);
            if( set.size() > samples ) samples = set.size();
        }
    }
    
    
    /*
    * Calculate min and max boundaries for stacked chart, and largest number of sample
    */
    private void calcStackedBounds() {
        FloatList stack = new FloatList();
        for(Set set : sets) {
            for(int i = 0; i < set.size(); i++) {
                if(i >= stack.size()) stack.set(i, set.value(i));
                else stack.add(i, set.value(i));
                //if(set.value(i) < min) min = floor(set.value(i));
            }
        }
        min = 0;
        max = ceil(stack.max());
        samples = stack.size();
    }
    
    
    /*
    * Draw the chart
    */
    public void draw() {
        
        ArrayList<Tooltip> tooltips = new ArrayList<Tooltip>();
        float[] stack = new float[samples]; 
        
        if(showAxisX) drawAxisX();
        if(showAxisY) drawAxisY();
        if(min < 0 && max > 0) drawAxis0();
        
        for(Set set : sets) {
            
            PVector prevPos = null;
            PVector prevPosStack = null;
            
            for(int i = 0; i < set.size(); i++) {
                
                PVector posStack = getPos(i, stack[i] + min);
                PVector pos = getPos(i, stack[i] + set.value(i));
                
                drawPos(set, prevPosStack, posStack, prevPos, pos);
                
                if( inChartMouse() ) {
                    if(mouseX > pos.x - 5 && mouseX < pos.x + 5) {
                        tooltips.add( new Tooltip(
                            tooltips,
                            pos,
                            String.format("%." + decimals + "f", set.value(i)) + set.unit,
                            set.tint
                        ));
                    }
                }
                
                prevPos = pos;
                prevPosStack = posStack;
                
                if(stacked) stack[i] += set.value(i);
                
            }
        }
        
        for(Threshold threshold : thresholds) {
            threshold.draw(this);
        }
        
        for(Tooltip tooltip : tooltips) {
            tooltip.draw();
        }
        
    }
    
    
    /*
    * Detects if mouse is over the chart
    * @return true if mouse over chart, false if not
    */
    protected boolean inChartMouse() {
        return mouseX > TL.x && mouseX < BR.x && mouseY > TL.y && mouseY < BR.y;
    }
    
    
    /*
    * Draw vertical axis (one per sample)
    */
    protected void drawAxisX() {
        fill(#DDDDDD); stroke(#DDDDDD); strokeWeight(1);
        textSize(9);
        for(int i = 0; i < samples; i++) {
            float x = lerp(TL.x, BR.x, (float) i / (samples- 1));
            line(x, TL.y, x, BR.y);
            textAlign(CENTER, TOP);
            text(i, x, BR.y + 2);
        }
    }
    
    
    /*
    * Draw horizontal axis
    */
    protected void drawAxisY() {
        fill(#DDDDDD); stroke(#DDDDDD); strokeWeight(1);
        textSize(9);
        int divs = 5;
        for(int i = 0; i <= divs ; i++) {
            float y = lerp(BR.y, TL.y, (float) i / divs );
            line(TL.x, y, BR.x, y);
            float value = map(y, BR.y, TL.y, min, max);
            textAlign(LEFT, BOTTOM);
            text(String.format("%." + decimals + "f", value), TL.x + 2, y);
        }
    }
    
    
    /*
    * Draw axis in 0 position
    */
    protected void drawAxis0(){
        float pos0 = getPos(0);
        line(TL.x, pos0, BR.x, pos0);
        textAlign(LEFT, BOTTOM);
        text(0, TL.x + 2, pos0);
    }
    
    
    /*
    * Get screen position for a specific value inside the chart
    * @param x x value
    * @param y y value
    * @return vector position
    */
    protected PVector getPos(int x, float y) {
        return new PVector(
            map(x, 0, samples - 1, TL.x, BR.x),
            getPos(y)
        );
    }
    
    
    /*
    * Get vertical position for a value
    * @param y y value
    * @return y position
    */
    protected float getPos(float y) {
        return map(y, min, max, BR.y, TL.y);
    }
    
    
    
    protected abstract void drawPos(Set set, PVector prevPosStack, PVector posStack, PVector prevPos, PVector pos );
    
       
}


public class DotChart extends Chart {

    public DotChart(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
    }
    
    
    protected void drawPos(Set set, PVector prevPosStack, PVector posStack, PVector prevPos, PVector pos) {
        fill(set.tint); noStroke();
        ellipse(pos.x, pos.y, 5, 5);
    }
    
}



public class LineChart extends Chart {

    public LineChart(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
    }
    
    
    protected void drawPos(Set set, PVector prevPosStack, PVector posStack, PVector prevPos, PVector pos) {
        fill(set.tint); noStroke();
        ellipse(pos.x, pos.y, 5, 5);
        stroke(set.tint); strokeWeight(1);
        if(prevPos != null) line(prevPos.x, prevPos.y, pos.x, pos.y);
    }
    
}




public class AreaChart extends Chart {

    public AreaChart(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
    }
    
    
    protected void drawPos(Set set, PVector prevPosStack, PVector posStack, PVector prevPos, PVector pos) {
        
        fill(set.tint, 50); noStroke();
        if(prevPos != null && prevPosStack != null) {
            
            beginShape();
            vertex(prevPosStack.x, prevPosStack.y);
            vertex(prevPos.x, prevPos.y);
            vertex(pos.x, pos.y);
            vertex(posStack.x, posStack.y);
            endShape(CLOSE);
            
            stroke(set.tint); strokeWeight(1);
            line(prevPos.x, prevPos.y, pos.x, pos.y);
        }
        
    }
    
}



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




private class Threshold {

    private String name;
    private float min, max;
    private color tint;
    
    Threshold(String name, float min, float max, color tint) {
        this.name = name;
        this.min = min;
        this.max = max;
        this.tint = tint;
    }
    
    protected void draw(Chart chart) {
        
        float posMin = min(chart.BR.y, chart.getPos(min));
        float posMax = min != max ? max(chart.TL.y, chart.getPos(max)) : posMin;
        
        fill(tint, 100); stroke(tint); strokeWeight(1); rectMode(CORNERS);
        rect(chart.TL.x, posMin, chart.BR.x, posMax);
        
        fill(tint); textAlign(LEFT, BOTTOM);
        text(name, chart.TL.x + 3, posMin);
        
    }
    
}



private class Tooltip {
    
    private PVector pos;
    private String label;
    private color tint;
    
    
    Tooltip(ArrayList<Tooltip> tooltips, PVector pos, String label, color tint) {
        this.pos = pos.copy().sub(0, 14);
        this.label = label;
        this.tint = tint;
        for(Tooltip t : tooltips) {
            // Tooltips horizontal overlap
            if( abs( t.pos.x - this.pos.x ) < ( textWidth(this.label)) / 2 + ( textWidth(t.label) ) / 2 ) {  
                float dY = t.pos.y - this.pos.y;
                // Tooltips vertical overlap
                if( dY > -20 && dY < 20 ) this.pos.y -= ( dY == 0 ) ? 20 : Math.signum(dY) * ( 20 - abs(dY) + 1 );
            }
        }
    }
    
    
    public void draw() {
        fill(tint); noStroke(); rectMode(CENTER);
        rect(pos.x, pos.y, textWidth(label) + 15, 20, 3);
        textAlign(CENTER, CENTER); textSize(9);
        fill(#FFFFFF);
        text(label, pos.x, pos.y - 1);
    }
    
    
}