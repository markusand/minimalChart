protected abstract class Cartesian extends Chart {
    
    Cartesian(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
        plotMin = new PVector(0, size.y);
        plotMax = new PVector(size.x, 0);
    }
    
    
    protected void drawAxis(boolean x, boolean y) {
        
        if(x) {  
            for(int i = minX.x; i <= maxX.x; i++) {
                PVector axisBottom = getPosition(i, minY.y);
                PVector axisTop = getPosition(i, maxY.y);
                drawLine(axisBottom, axisTop, #DDDDDD, 1);
                
                fill(#DDDDDD); textSize(9); textAlign(CENTER, TOP);
                if( labels.containsKey(i) ) {
                    if(i == minX.x) textAlign(LEFT, TOP);
                    else if(i == maxX.x) textAlign(RIGHT, TOP);
                    text(labels.get(i), axisBottom.x, axisBottom.y + 2);
                }
            }
        }
        
    }
    
}




public class Scatter extends Cartesian {
    
    int dotSize = 5;
    
    Scatter(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    
    @Override  // Prevent making DOT chart stacked
    public void stacked(boolean stacked) {}
    
    
    protected void drawSet(FloatList stack, Set set) {
        for(Datum d : set.data()) {
            PVector pos = getPosition(d.x, d.y);
            
            boolean isClose = isClose( mousePos(), pos,  20, size.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", d.y) + set.units, set.tint));
            
            drawDot(pos, set.tint, 5);
        }
    }
    
}




public class Lines extends Cartesian {
    
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
            PVector pos = getPosition(d.x, stackValue + d.y);
            
            boolean isClose = isClose( mousePos(), pos,  20, size.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", d.y) + set.units, set.tint));
            
            if(prevPos != null) drawLine(prevPos, pos, set.tint, 1);
            drawDot(pos, set.tint, isClose ? 2 * dotSize : dotSize);
            
            prevPos = new PVector(pos.x, pos.y);
        }
        
    }
    
}




public class Area extends Cartesian {
    
    int opacity = 70;
    
    Area(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    protected void drawSet(FloatList stack, Set set) {
        PVector prevPos = null;
        PVector prevStack = null;
        
        for(int i = 0; i < set.size(); i++) {
            Datum d = set.get(i);
            
            float stackValue = stack.size() > 0 ? stack.get(i) : minY.y;
            PVector stackPos = getPosition(d.x, stackValue);
            PVector pos = getPosition(d.x, stackValue + d.y);
            
            boolean isClose = isClose( mousePos(), pos,  20, size.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", d.y) + set.units, set.tint));
            
            if(prevPos != null && prevStack != null) {
                drawArea(prevStack, prevPos, pos, stackPos, color(set.tint, opacity));
                drawLine(prevPos, pos, set.tint, 1);
            }
            
            prevPos = pos;
            prevStack = stackPos;
        }
    }
    
}