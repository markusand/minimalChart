protected abstract class Polar extends Chart {
    
    protected PVector center;
    protected float R;

    protected Polar(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
        center = new PVector(width / 2, height / 2);
        R = min(center.x, center.y);
        plotMin = new PVector(0, 0);
        plotMax = new PVector(TWO_PI, R);
    }
    
    
    @Override  // Prevent to change stacked option
    public Chart stacked(boolean stacked) { return this; }
    
    
    @Override
    protected boolean isClose(PVector point, PVector ref, float dx, float dy) {
        return point.mag() < dx && PVector.angleBetween(ref, point) < dy;
    }
    
    
    protected void textAlignPolar(float angle) {
        int h = angle == 0 || angle == PI ? CENTER : angle < PI ? LEFT : RIGHT;
        int v = angle == HALF_PI || angle == 3 * HALF_PI ? CENTER : angle < HALF_PI || angle > 3 * HALF_PI ? BOTTOM : TOP;
        textAlign(h, v);
    }

}




public class Radar extends Polar {
    
    Radar(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
    }
    
    
    @Override // Center (minY) to 0
    protected PVector getPosition(int x, float y) {
        return new PVector(
            map(x, minX.x, maxX.x+1, plotMin.x, plotMax.x),
            map(y, 0, maxY.y, plotMin.y, plotMax.y)
        );
    }
    
    
    protected void drawAxis(boolean x, boolean y) {
        pushMatrix();
        translate(center.x, center.y);
        
        for(int i = minX.x; i <= maxX.x; i++) {
            PVector polarVertex = getPosition(i, maxY.y);
            PVector vertex = CoordinateSystem.toCartesian(polarVertex.y, -HALF_PI + polarVertex.x);
            fill(#DDDDDD); textSize(9); textAlign(CENTER, CENTER);
            if( labels.containsKey(i) ) {
                textAlignPolar(polarVertex.x);
                text(labels.get(i), vertex.x, vertex.y);
            }
        }
        
        rotate(-HALF_PI);
        noFill(); stroke(#DDDDDD); strokeWeight(1);
        
        int vertices = maxX.x - minX.x;
        for(int i = 0; i <= 4; i++) polygon(0, 0, i * R / 4, vertices);
        
        popMatrix();
    }
    
    
    protected void drawSet(FloatList stack, Set set) {
        pushMatrix();
        translate(center.x, center.y);
        rotate(-HALF_PI);
        
        fill(set.tint, 70); stroke(set.tint); strokeWeight(1);
        beginShape();
        for(Datum d : set.data()) {
            
            PVector polarPos = getPosition(d.x, d.y);
            PVector pos = CoordinateSystem.toCartesian(polarPos.y, polarPos.x);
            
            vertex(pos.x, pos.y);
            
            PVector mousePos = mousePos().sub(center).rotate(HALF_PI);
            boolean isClose = isClose(mousePos, pos, R, PI / set.size() );
            
            if(isClose) tooltips.add( new Tooltip(
                tooltips,
                pos.rotate(-HALF_PI).add(center),
                d.label + " " + String.format("%." + decimals + "f", d.y) + set.units,
                set.tint
            ));
            
        }
        endShape(CLOSE);
        
        popMatrix();
    }
    
    
    private void polygon(int x, int y, float R, int vertices) {
        float angle = TWO_PI / (vertices + 1);
        beginShape(TRIANGLE_FAN);
        vertex(x, y);
        for(float a = 0; a < TWO_PI; a += angle) {
            PVector vertex = CoordinateSystem.toCartesian(R, a).add(x, y);
            vertex(vertex.x, vertex.y);
        }
        vertex(y + R, x);
        endShape();
    }
    
}




public class Pie extends Polar {
    
    private float donutWidth = Float.NaN;
    private boolean showLabels = true;
    
    public Pie(int x, int y, int width, int height) {
        super(x, y, width, height);
        plotMin = new PVector(0, 0);
        plotMax = new PVector(R, TWO_PI);
        stacked = true;
    }
    
    public Pie(int x, int y, int width, int height, float dWidth) {
        this(x, y, width, height);
        this.donutWidth = dWidth;
    }
    
    
    public Chart showLabels(boolean labels) {
        showLabels = labels;
        return this;
    }
    
    
    @Override
    protected void calcStackedBounds() {
        float sum = 0;
        int amount = 0;
        for(Set set : sets) {
            for(Datum datum : set.data()) {
                sum += datum.y;
                amount++;
            }
        }
        minX = minY = new Datum(0, 0, "MIN");
        maxX = maxY = new Datum(amount, sum, "MAX");
    }
    
    
    protected void drawSet(FloatList stack, Set set) {
        
        pushMatrix();
        translate(center.x, center.y);
        
        float total = 0;
        for(int i = 0; i < stack.size(); i++) total += stack.get(i);
        
        float prevAngle = stack.size() > 0 ? getPosition(0, total).y : 0;
        for(Datum d : set.data()) {
            
            float angle = getPosition(0, d.y).y;
            float midPoint = prevAngle + angle / 2; 
            
            fill(set.tint); stroke(#FFFFFF);
            arc(0, 0, 2*R, 2*R, prevAngle, prevAngle + angle, PIE);
            
            if( !Float.isNaN(donutWidth) ) drawDot(0, 0, #FFFFFF, int(2 * (R-donutWidth)));
            
            PVector mousePos = mousePos().sub(center);
            PVector point = CoordinateSystem.toCartesian(R, midPoint);
            boolean isClose = isClose(mousePos, point, R, angle / 2 );
            
            if(isClose) tooltips.add( new Tooltip(
                tooltips,
                mousePos.add(center),
                String.format("%." + decimals + "f", d.y) + set.units,
                set.tint
            ));
            
            if(showLabels) {
                pushMatrix();
                rotate(midPoint);
                translate(2*R/3, 0);
                if(midPoint > HALF_PI && midPoint < 3 * HALF_PI) rotate(-PI);
                fill(#FFFFFF); textSize(9); textAlign(CENTER, CENTER);
                text(d.label, 0, 0);
                popMatrix();
            }
            
            prevAngle += angle;
        }
        
        popMatrix();
    }
    
    
    protected void drawAxis(boolean x, boolean y) {}

}