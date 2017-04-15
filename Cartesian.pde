/**
* Define a chart with cartesian coordinates. Axis are lineal in the X and Y direction
* @author       Marc Vilella
*/
protected abstract class CartesianChart extends Chart {
    
    /**
    * Create a chart in cartesian coordinates
    * @param TLx        the x coordinate of Top-Left corner
    * @param TLy        the y coordinate of Top-Left corner
    * @param width      the width of the chart
    * @param height     the height of the chart
    */
    protected CartesianChart(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
        limitsMin = new PVector(0, SIZE.y);
        limitsMax = new PVector(SIZE.x, 0);
    }
    
    
    /**
    * Draw chart axis if required
    */
    protected void drawAxis() {
        if(showAxisX) {  
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



/**
* Scatterplots use a collection of points placed using Cartesian Coordinates to display values from
* two variables. By displaying a variable in each axis, you can detect if a relationship or correlation
* between the two variables exists.
*/
public class ScatterChart extends CartesianChart {
    
    private int dotSize = 5;
    
    /**
    * Create a scatter chart in cartesian coordinates
    * @see CartesianChart
    */
    ScatterChart(int x, int y, int width, int height) {
        super(x, y, width, height);
        stackable = false;
    }
    
    
    /**
    * Draw a dataset
    * @see Chart
    */
    protected void drawDataSet(int setNum, DataSet set, FloatList stack) {
        float dX = (float)(limitsMax.x - limitsMin.x) / (maxX.x - minX.x);
        
        for(Datum datum : set.data()) {
            PVector pos = getPosition(datum.x, datum.y);
            
            boolean isClose = isClose( mousePos(), pos,  dX/2, SIZE.y);
            if(isClose) tooltips.add(new Tooltip(tooltips, pos, String.format("%." + decimals + "f", datum.y) + set.UNITS, set.COLOR));
            
            drawDot(pos, set.COLOR, dotSize);
        }
    }
    
}



/**
* Line Graphs are used to display quantitative value over a continuous interval or time span. It is most
* frequently used to show trends and relationships (when grouped with other lines). Line Graphs also help
* to give a "big picture" over an interval, to see how it has developed over that period
*/
public class LineChart extends CartesianChart {
    
    private int dotSize;
    private int lineStroke;
    
    /**
    * Create a line chart in cartesian coordinates
    * @see CartesianChart
    * @param dotSize       the size of datum point dots
    * @param lineStroke    the stroke width of the lines
    */
    LineChart(int x, int y, int width, int height, int dotSize, int lineStroke) {
        super(x, y, width, height);
        this.dotSize = dotSize;
        this.lineStroke = lineStroke;
    }
    
    
    /**
    * Draw a dataset
    * @see Chart
    */
    protected void drawDataSet(int setNum, DataSet set, FloatList stack) {
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



/**
* rea Graphs are used to display the development of quantitative values over an interval or time period.
* They are most commonly used to show trends, rather then convey specific values
*/
public class AreaChart extends CartesianChart {
    
    private int opacity;
    
    /**
    * Create an area chart in cartesian coordinates
    * @see CartesianChart
    * @param opacity    the area opacity
    */
    AreaChart(int x, int y, int width, int height, int opacity) {
        super(x, y, width, height);
        this.opacity = opacity;
    }
    
    
    /**
    * Draw a dataset
    * @see Chart
    */
    protected void drawDataSet(int setNum, DataSet set, FloatList stack) {
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


/**
* Bar Chart show discrete, numerical comparisons across categories. One axis of the chart shows the specific
* categories being compared and the other axis represents a discrete value scale.
*/
public class BarChart extends CartesianChart {

    private int opacity = 80;
    
    
    /**
    * Create a bar chart in cartesian coordinates
    * @see CartesianChart
    */
    public BarChart(int x, int y, int width, int height) {
        super(x, y, width, height);
    }
    
    
    /**
    * Draw axis if required
    */
    @Override
    protected void drawAxis() {
        if(showAxisX) {
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
    
    
    /**
    * Draw a dataset
    * @see Chart
    */
    protected void drawDataSet(int setNum, DataSet set, FloatList stack) {
        
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