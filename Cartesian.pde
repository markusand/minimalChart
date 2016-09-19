public class Dots extends Chart {
    
    int dotSize = 5;
    
    Dots(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    
    @Override  // Prevent making DOT chart stacked
    public void stacked(boolean stacked) {}
    
    
    protected void drawSet(FloatList stack, Set set) {
        for(Datum d : set.getAll()) {
            PVector pos = getPosition(d.getX(), d.getY());
            boolean isClose = isClose( mousePos(), pos,  20, size.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", d.getY()) + set.getUnits(), set.getColor()));
            drawDot(pos, set.getColor(), 5);
        }
    }
    
}




public class Lines extends Chart {
    
    int dotSize = 5;
    int lineStroke = 1;
    
    Lines(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    protected void drawSet(FloatList stack, Set set) {
        PVector prevPos = null;
        for(int i = 0; i < set.size(); i++) {
            Datum d = set.get(i);
            float stackValue = stack.size() > 0 ? stack.get(i) : 0;
            PVector pos = getPosition(d.getX(), stackValue + d.getY());
            boolean isClose = isClose( mousePos(), pos,  20, size.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", d.getY()) + set.getUnits(), set.getColor()));
            if(prevPos != null) drawLine(prevPos, pos, set.getColor(), 1);
            drawDot(pos, set.getColor(), isClose ? 2 * dotSize : dotSize);
            prevPos = new PVector(pos.x, pos.y);
        }
        
    }
    
}



public class Area extends Chart {
    
    int opacity = 70;
    
    Area(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    protected void drawSet(FloatList stack, Set set) {
        PVector prevPos = null;
        PVector prevStack = null;
        for(int i = 0; i < set.size(); i++) {
            Datum d = set.get(i);
            float stackValue = stack.size() > 0 ? stack.get(i) : minY.getY();
            PVector stackPos = getPosition(d.getX(), stackValue);
            PVector pos = getPosition(d.getX(), stackValue + d.getY());
            boolean isClose = isClose( mousePos(), pos,  20, size.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", d.getY()) + set.getUnits(), set.getColor()));
            if(prevPos != null && prevStack != null) {
                drawArea(prevStack, prevPos, pos, stackPos, color(set.getColor(), opacity));
                drawLine(prevPos, pos, set.getColor(), 1);
            }
            prevPos = pos;
            prevStack = stackPos;
        }
    }
    
}