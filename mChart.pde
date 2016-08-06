public class Set {

    protected String name;
    protected String unit;
    protected color tint;
    
    private FloatList values = new FloatList();
    protected float min = Float.MAX_VALUE;
    protected float max = Float.MIN_VALUE;
    
    
    Set(String name, String unit, color tint) {
        this.name = name;
        this.unit = unit;
        this.tint = tint;
    }
    
    
    public void add(float... values) {
        for(float value : values) {
            this.values.append(value);
            if(value < min) min = value;
            if(value > max) max = value;
        }
    }
    
    
    public float value(int i) {
        if( i < values.size() ) return values.get(i);
        else return 0;
    }
    
    
    public int size() { return values.size(); }
    
    
}




public abstract class Chart {

    protected PVector TL;
    protected PVector BR;
    
    protected int margin;
    
    protected boolean showAxisX;
    protected boolean showAxisY;
    protected int decimals = 1;
    
    protected ArrayList<Set> sets = new ArrayList<Set>();   
    protected float min = Float.MAX_VALUE;
    protected float max = Float.MIN_VALUE;
    protected int samples = 0;
    
    
    
    public Chart(int TLx, int TLy, int width, int height) {
        TL = new PVector(TLx, TLy);
        BR = new PVector(TLx + width, TLy + height);
    }
    
    
    public void decimals(int i) { decimals = i; }
    
    public void showAxis(boolean axisX, boolean axisY) {
        showAxisX = axisX;
        showAxisY = axisY;
    }
    
    
    public void clear() {
        sets.clear();
        min = Float.MAX_VALUE;
        max = Float.MIN_VALUE;
        samples = 0;
    }
    
    
    public void add(Set... sets) {
        for(Set set : sets) {
            this.sets.add(set);
            if( set.min < min ) min = floor(set.min);
            if( set.max > max ) max = ceil(set.max);
            if( set.size() > samples ) samples = set.size();
        }
    }
    
    
    public void draw() {
        
        ArrayList<Tooltip> tooltips = new ArrayList<Tooltip>();
        
        drawAxis();
        
        for(Set set : sets) {
            PVector prevPos = null;
            for(int i = 0; i < set.size(); i++) {
                
                PVector pos = getPos(set, i);
                drawPos(set, prevPos, pos);
                
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
            }
        }
        
        for(Tooltip tooltip : tooltips) {
            tooltip.draw();
        }
        
    }
    
    
    private boolean inChartMouse() {
        return mouseX > TL.x && mouseX < BR.x && mouseY > TL.y && mouseY < BR.y;
    }
    
    
    protected void drawAxis() {
        
        fill(#DDDDDD); stroke(#DDDDDD); strokeWeight(1);
        textSize(9);
        
        if(min < 0 && max > 0) {
            float pos0 = pos0();
            line(TL.x, pos0, BR.x, pos0);
            textAlign(LEFT, BOTTOM);
            text(0, TL.x + 2, pos0);
        }
        
        if( showAxisX ) {
            for(int i = 0; i < samples; i++) {
                float x = lerp(TL.x, BR.x, (float) i / (samples- 1));
                line(x, TL.y, x, BR.y);
                textAlign(CENTER, TOP);
                text(i, x, BR.y + 2);
            }
        }
        
        if( showAxisY ) {
            int divs = 5;
            for(int i = 0; i <= divs ; i++) {
                float y = lerp(BR.y, TL.y, (float) i / divs );
                line(TL.x, y, BR.x, y);
                float value = map(y, BR.y, TL.y, min, max);
                textAlign(LEFT, BOTTOM);
                text(String.format("%." + decimals + "f", value), TL.x + 2, y);
            }
        }
        
    }
    
    
    private PVector getPos(Set set, int i) {
        return new PVector(
            map(i, 0, samples - 1, TL.x, BR.x),
            map(set.value(i), min, max, BR.y, TL.y)
        );
    }
    
    protected float pos0() {
        return map(0, min, max, BR.y, TL.y);
    }
    
    protected abstract void drawPos(Set set, PVector prevPos, PVector pos );
    
       
}


public class DotChart extends Chart {

    public DotChart(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
    }
    
    
    protected void drawPos(Set set, PVector prevPos, PVector pos) {
        fill(set.tint); noStroke();
        ellipse(pos.x, pos.y, 5, 5);
    }
    
}



public class LineChart extends Chart {

    public LineChart(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
    }
    
    
    protected void drawPos(Set set, PVector prevPos, PVector pos) {
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
    
    
    public void drawPos(Set set, PVector prevPos, PVector pos) {
        
        fill(set.tint, 50); noStroke();
        if(prevPos != null) {
            
            float pos0 = pos0();
            
            beginShape();
            vertex(prevPos.x, pos0);
            vertex(prevPos.x, prevPos.y);
            vertex(pos.x, pos.y);
            vertex(pos.x, pos0);
            endShape();
            
            stroke(set.tint); strokeWeight(1);
            line(prevPos.x, prevPos.y, pos.x, pos.y);
        }
        
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