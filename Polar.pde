protected abstract class Polar extends Chart {
    
    protected PVector center;
    protected float minR, maxR;

    protected Polar(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
        center = new PVector(width / 2, height / 2);
        maxR = min(center.x, center.y);
        limitsMin = new PVector(0, 0);
        limitsMax = new PVector(TWO_PI, maxR);
    }
    
    
    @Override  // Prevent to change stacked option
    public Chart stacked(boolean stacked) { return this; }
    
    
    @Override
    protected boolean isClose(PVector point, PVector ref, float dx, float dy) {
        float pointR = point.mag();
        return pointR > minR && pointR < maxR && PVector.angleBetween(ref, point) < dy;
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
        showAxis(true, true);
    }
    
    
    @Override // Center (minY) to 0
    protected PVector getPosition(int x, float y) {
        return new PVector(
            map(x, minX.x, maxX.x+1, limitsMin.x, limitsMax.x),
            map(y, 0, maxY.y, limitsMin.y, limitsMax.y)
        );
    }
    
    
    protected void drawAxis(boolean showX, boolean showY) {
        pushMatrix();
        translate(center.x, center.y);
        
        if(showX) {
            for(int i = minX.x; i <= maxX.x; i++) {
                PVector polarVertex = getPosition(i, maxY.y);
                PVector vertex = CoordinateSystem.toCartesian(polarVertex.y, -HALF_PI + polarVertex.x);
                fill(#DDDDDD); textSize(9); textAlign(CENTER, CENTER);
                if( labels.containsKey(i) ) {
                    textAlignPolar(polarVertex.x);
                    text(labels.get(i), vertex.x, vertex.y);
                }
            }
        }
        
        if(showY) {
            rotate(-HALF_PI);
            noFill(); stroke(#DDDDDD); strokeWeight(1);
            int vertices = maxX.x - minX.x;
            for(int i = 0; i <= 4; i++) polygon(0, 0, i * maxR / 4, vertices);
        }
        
        popMatrix();
    }
    
    
    protected void drawSet(int setNum, Set set, FloatList stack) {
        pushMatrix();
        translate(center.x, center.y);
        rotate(-HALF_PI);
        
        fill(set.COLOR, 70); stroke(set.COLOR); strokeWeight(1);
        beginShape();
        for(Datum datum : set.data()) {
            
            PVector polarPos = getPosition(datum.x, datum.y);
            PVector pos = CoordinateSystem.toCartesian(polarPos.y, polarPos.x);
            
            vertex(pos.x, pos.y);
            
            PVector mousePos = mousePos().sub(center).rotate(HALF_PI);
            boolean isClose = isClose(mousePos, pos, maxR, PI / set.size() );
            
            if(isClose) tooltips.add( new Tooltip(
                tooltips,
                pos.rotate(-HALF_PI).add(center),
                datum.LABEL + " " + String.format("%." + decimals + "f", datum.y) + set.UNITS,
                set.COLOR
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
    private boolean showLabels = false;
    
    public Pie(int x, int y, int width, int height) {
        super(x, y, width, height);
        limitsMin = new PVector(0, 0);
        limitsMax = new PVector(maxR, TWO_PI);
        stacked = true;
    }
    
    public Pie(int x, int y, int width, int height, float dWidth) {
        this(x, y, width, height);
        this.minR = maxR - dWidth;
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
    
    
    protected void drawSet(int setNum, Set set, FloatList stack) {
        
        pushMatrix();
        translate(center.x, center.y);
        
        float total = 0;
        for(int i = 0; i < stack.size(); i++) total += stack.get(i);
        
        float prevAngle = stack.size() > 0 ? getPosition(0, total).y : 0;
        for(Datum datum : set.data()) {
            
            float angle = getPosition(0, datum.y).y;
            float midPoint = prevAngle + angle / 2; 
            
            fill(set.COLOR); stroke(#FFFFFF);
            arc(0, 0, 2*maxR, 2*maxR, prevAngle, prevAngle + angle, PIE);
            
            if( minR > 0 ) drawDot(0, 0, #FFFFFF, int(2 * minR));
            
            PVector mousePos = mousePos().sub(center);
            PVector point = CoordinateSystem.toCartesian(maxR, midPoint);
            boolean isClose = isClose(mousePos, point, 0, angle / 2 );  // dX value is not used
            
            if(isClose) tooltips.add( new Tooltip(
                tooltips,
                mousePos.add(center),
                String.format("%." + decimals + "f", datum.y) + set.UNITS,
                set.COLOR
            ));
            
            if(showLabels) {
                pushMatrix();
                rotate(midPoint);
                translate(2 * maxR / 3, 0);
                if(midPoint > HALF_PI && midPoint < 3 * HALF_PI) rotate(-PI);
                fill(#FFFFFF); textSize(9); textAlign(CENTER, CENTER);
                text(datum.LABEL, 0, 0);
                popMatrix();
            }
            
            prevAngle += angle;
        }
        
        popMatrix();
    }
    
    
    protected void drawAxis(boolean showX, boolean showY) {}

}