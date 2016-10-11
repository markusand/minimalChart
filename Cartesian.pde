protected abstract class Cartesian extends Chart {
    
    protected Cartesian(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
        limitsMin = new PVector(0, SIZE.y);
        limitsMax = new PVector(SIZE.x, 0);
    }
    
    
    protected void drawAxis(boolean showX, boolean showY) {
        if(showX) {  
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
    
    private int dotSize = 5;
    
    Scatter(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    
    @Override  // Prevent making DOT chart stacked
    public Chart stacked(boolean stacked) { return this; }
    
    
    protected void drawSet(int setNum, Set set, FloatList stack) {
        float dX = (float)(limitsMax.x - limitsMin.x) / (maxX.x - minX.x);
        
        for(Datum datum : set.data()) {
            PVector pos = getPosition(datum.x, datum.y);
            
            boolean isClose = isClose( mousePos(), pos,  dX/2, SIZE.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", datum.y) + set.UNITS, set.COLOR));
            
            drawDot(pos, set.COLOR, 5);
        }
    }
    
}



public class Lines extends Cartesian {
    
    private int dotSize = 7;
    private int lineStroke = 1;
    
    Lines(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    protected void drawSet(int setNum, Set set, FloatList stack) {
        PVector prevPos = null;
        float dX = (float)(limitsMax.x - limitsMin.x) / (maxX.x - minX.x);
        
        for(int i = 0; i < set.size(); i++) {
            Datum datum = set.get(i);
            
            float stackValue = stack.size() > 0 ? stack.get(i) : 0;
            PVector pos = getPosition(datum.x, stackValue + datum.y);
            
            boolean isClose = isClose( mousePos(), pos,  dX/2, SIZE.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", datum.y) + set.UNITS, set.COLOR));
            
            if(prevPos != null) drawLine(prevPos, pos, set.COLOR, lineStroke);
            drawDot(pos, set.COLOR, isClose ? dotSize + 3 : dotSize);
            
            prevPos = new PVector(pos.x, pos.y);
        }
    }
    
}



public class Area extends Cartesian {
    
    private int opacity = 70;
    
    Area(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    
    public void setOpacity(int opacity) {
        this.opacity = opacity;
    }
    
    
    protected void drawSet(int setNum, Set set, FloatList stack) {
        PVector prevPos = null;
        PVector prevStack = null;
        
        float dX = (float)(limitsMax.x - limitsMin.x) / (maxX.x - minX.x);
        
        for(int i = 0; i < set.size(); i++) {
            Datum datum = set.get(i);
            
            float stackValue = stack.size() > 0 ? stack.get(i) : minY.y;
            PVector stackPos = getPosition(datum.x, stackValue);
            PVector pos = getPosition(datum.x, stackValue + datum.y);
            
            boolean isClose = isClose( mousePos(), pos,  dX/2, SIZE.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", datum.y) + set.UNITS, set.COLOR));
            
            if(prevPos != null && prevStack != null) {
                drawArea(prevStack, prevPos, pos, stackPos, color(set.COLOR, opacity));
                drawLine(prevPos, pos, set.COLOR, 1);
            }
            
            prevPos = pos;
            prevStack = stackPos;
        }
        
    }
    
}



public class Bars extends Cartesian {

    private int opacity = 80;
    
    public Bars(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    
    public void setOpacity(int opacity) {
        this.opacity = opacity;
    }
    
    
    @Override
    protected void drawAxis(boolean showX, boolean showY) {
        if(showX) {
            float dX = (float)(limitsMax.x - limitsMin.x) / (maxX.x - minX.x + 1);
            int i = minX.x;
            for(float x = 0; x <= SIZE.x; x += dX) {
                noFill(); stroke(#DDDDDD); strokeWeight(1);
                line(x, 0, x, limitsMin.y);
                fill(#DDDDDD); textSize(9); textAlign(CENTER, TOP);
                if( labels.containsKey(i) ) text(labels.get(i), x + dX / 2, limitsMin.y + 2);
                i++;
            }
        }
    }
    
    
    protected void drawSet(int setNum, Set set, FloatList stack) {
        
        float dX = (float)(limitsMax.x - limitsMin.x) / (maxX.x - minX.x + 1);
        float barW = stacked ? dX : dX / sets.size();
        
        for(int i = 0; i < set.size(); i ++) {
            Datum datum = set.get(i);
            
            float stackValue = stack.size() > 0 ? stack.get(i) : minY.y;
            PVector stackPos = new PVector(datum.x * dX, map(stackValue, minY.y, maxY.y, limitsMin.y, limitsMax.y));
            
            PVector pos = new PVector(stackPos.x, map(stackValue + datum.y, minY.y, maxY.y, limitsMin.y, limitsMax.y));
            if(!stacked) pos.add(setNum * barW, 0);
            
            rectMode(CORNERS); fill(set.COLOR, opacity); stroke(set.COLOR); strokeWeight(1);
            rect(pos.x, stackPos.y, pos.x + barW, pos.y);
            
            boolean isClose = isClose(mousePos(), new PVector(dX * (datum.x + 0.5), SIZE.y / 2), dX / 2, SIZE.y );
            if(isClose) tooltips.add( new Tooltip(
                tooltips,
                pos.add(barW / 2, 0),
                String.format("%." + decimals + "f", datum.y) + set.UNITS,
                set.COLOR
            ));
            
        }
    }
    
}