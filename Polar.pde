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
            for(Datum datum : set.getAll()) {
                sum += datum.getY();
                amount++;
            }
        }
        minX = minY = new Datum(0, 0, "MIN");
        maxX = maxY = new Datum(amount, sum, "MAX");
    }
    
    
    @Override  // Prevent making PIE chart non-stacked
    public void stacked(boolean stacked) {}
    
    
    @Override
    protected void drawAxis(boolean x, boolean y) {}

    
    protected void drawSet(FloatList stack, Set set) {
        
        pushMatrix();
        translate(center.x, center.y);
        
        float total = 0;
        for(int i = 0; i < stack.size(); i++) total += stack.get(i);
        
        float prevAngle = stack.size() > 0 ? getPosition(0, total).y : 0;
        for(Datum d : set.getAll()) {
            
            float angle = getPosition(0, d.getY()).y;
            
            PVector polarMouse = CoordinateSystem.toPolarUnsigned( mousePos().sub(center) );
            float dx = (R-r) / 2;
            boolean isClose = isClose( polarMouse, new PVector(r + dx, prevAngle + angle / 2), dx, angle / 2);
            if(isClose) tooltips.add(new Tooltip(tooltips, mousePos(), d.getLabel() + " " + String.format("%." + decimals + "f", d.getY()) + set.getUnits(), set.getColor()));
            
            fill(set.getColor(), isClose ? 255 : 220); noStroke();
            arc(0, 0, 2*R, 2*R, prevAngle, prevAngle + angle, PIE);
            drawDot(0, 0, #FFFFFF, int(2*r));
            
            prevAngle += angle;
        }
        
        popMatrix();
    }

}