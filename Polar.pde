public class Radar extends Chart {

    float R;
    PVector center;
    
    Radar(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
        center = new PVector(width / 2, height / 2);
        R = min(center.x, center.y);
        plotMin = new PVector(0, 0);
        plotMax = new PVector(TWO_PI, R);
    }
    
    
    @Override  // Prevent to make Radar chart stacked
    public void stacked(boolean stacked) {}
    
    
    @Override
    protected PVector getPosition(int x, float y) {
        return new PVector(
            map(x, minX.x, maxX.x+1, plotMin.x, plotMax.x),
            map(y, 0, maxY.y, plotMin.y, plotMax.y)
        );
    }
    
    
    protected void drawAxis(boolean x, boolean y) {
        pushMatrix();
        translate(center.x, center.y);
        rotate(-HALF_PI);
        noFill(); stroke(#DDDDDD); strokeWeight(1);
        int vertices = maxX.x - minX.x;
        for(int i = 0; i <= 4; i++) {
            polygon(0, 0, i * R / 4, vertices);
        }
        
        
        popMatrix();
    }
    
    
    protected void drawSet(FloatList stack, Set set) {
        pushMatrix();
        translate(center.x, center.y);
        rotate(-HALF_PI);
        fill(set.tint, 70); stroke(set.tint); strokeWeight(1);
        beginShape();
            for(int i=0; i < set.size(); i++) {
                Datum d = set.get(i);
                float stackValue = stack.size() > 0 ? stack.get(i) : 0;
                PVector polarPos = getPosition(d.x, stackValue + d.y);
                PVector pos = CoordinateSystem.toCartesian(polarPos.y, polarPos.x);
                vertex(pos.x, pos.y);
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




public class Pie extends Chart {

    PVector center;    
    float R;
    float r;
    
    public Pie(int x, int y, int width, int height) {
        super(x, y, width, height);
        plotMin = new PVector(0, 0);
        plotMax = new PVector(10, TWO_PI);
        stacked = true;
        
        center = new PVector(width / 2, height / 2);
        R = min(center.x, center.y);
        r = 0;
    }
    
    public Pie(int x, int y, int width, int height, int stroke) {
        this(x, y, width, height);
        r = R - stroke;
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
    
    
    @Override  // Prevent making PIE chart non-stacked
    public void stacked(boolean stacked) {}
    
    
    protected void drawAxis(boolean x, boolean y) {}

    
    protected void drawSet(FloatList stack, Set set) {
        
        pushMatrix();
        translate(center.x, center.y);
        
        float total = 0;
        for(int i = 0; i < stack.size(); i++) total += stack.get(i);
        
        float prevAngle = stack.size() > 0 ? getPosition(0, total).y : 0;
        for(Datum d : set.data()) {
            
            float angle = getPosition(0, d.y).y;
            
            PVector polarMouse = CoordinateSystem.toPolarUnsigned( mousePos().sub(center) );
            float dx = (R-r) / 2;
            boolean isClose = isClose( polarMouse, new PVector(r + dx, prevAngle + angle / 2), dx, angle / 2);
            if(isClose) tooltips.add(new Tooltip(tooltips, mousePos(), d.label + " " + String.format("%." + decimals + "f", d.y) + set.units, set.tint));
            
            fill(set.tint, isClose ? 255 : 200); noStroke();
            arc(0, 0, 2*R, 2*R, prevAngle, prevAngle + angle, PIE);
            drawDot(0, 0, #FFFFFF, int(2*r));
            
            prevAngle += angle;
        }
        
        popMatrix();
    }

}