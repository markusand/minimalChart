public class Pie extends Chart {

    PVector center;    
    float R;
    
    public Pie(int x, int y, int width, int height) {
        super(x, y, width, height);
        stacked = true;
        center = new PVector(width / 2, height / 2);
        R = min(center.x, center.y);
    }
    
    
    @Override
    protected void calcStackedBounds() {
        float total = 0;
        for(Set set : sets) {
            for(Datum datum : set.getAll()) total += datum.getY();
        }
        minX = minY = new Datum(0, 0, "MIN");
        maxX = maxY = new Datum(0, total, "MAX");
    }
    
    @Override  // Prevent making PIE chart non-stacked
    public void stacked(boolean stacked) {}
    
    
    @Override
    protected void drawAxis(boolean x, boolean y) {}

    @Override
    protected boolean isClose(PVector point, PVector ref, float dx, float dy) {
        return point.mag() < ref.mag() && PVector.angleBetween(point, ref) < dy;
    }
    
    
    private PVector polar2cart(float R, float angle) {
        return new PVector(
            R * cos(angle),
            R * sin(angle)
        );
    }
    
    private PVector cart2polar( PVector point ) {
        float length = point.mag();
        return new PVector(
            length,
            acos(point.x / length)
        );
    }
    
    
    protected void drawSet(FloatList stack, Set set) {
        pushMatrix();
        translate(center.x, center.y);
        float prevAngle = stack.size() > 0 ? map(stack.get(0), minY.getY(), maxY.getY(), 0, TWO_PI) : 0;
        for(Datum d : set.getAll()) {
            float angle = map(d.getY(), minY.getY(), maxY.getY(), 0, TWO_PI);
            PVector p = PVector.sub(mousePos(), center); 
            boolean isClose = isClose(p, polar2cart(R, prevAngle + angle / 2), R/2, angle / 2);
            if(isClose) tooltips.add(new Tooltip(tooltips, mousePos(), d.getLabel() + " " + String.format("%." + decimals + "f", d.getY()) + set.getUnits(), set.getColor()));
            fill(set.getColor(), isClose ? 255 : 220); noStroke();
            arc(0, 0, 2*R, 2*R, prevAngle, prevAngle + angle, PIE);
            prevAngle += angle;
        }
        popMatrix();
    }

}