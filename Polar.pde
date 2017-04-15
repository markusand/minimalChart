/**
* Define a chart with polar coordinates, characterized by a center, an angle and a radius
* @author       Marc Vilella
*/
protected abstract class PolarChart extends Chart {
    
    protected PVector center;
    protected float minR, maxR;

    /**
    * Create a chart in polar coordinates
    * @param TLx        the x coordinate of Top-Left corner
    * @param TLy        the y coordinate of Top-Left corner
    * @param width      the width of the chart
    * @param height     the height of the chart
    */
    protected PolarChart(int TLx, int TLy, int width, int height) {
        super(TLx, TLy, width, height);
        center = new PVector(width / 2, height / 2);
        maxR = min(center.x, center.y);
        limitsMin = new PVector(0, 0);
        limitsMax = new PVector(TWO_PI, maxR);
        stackable = false;
    }

    
    /**
    * Check wheter a point is close to a reference in the chart. In polar coordinates, the reference point is defined
    * by a radius and an angle, and the deviation is the radius variation and the angle variation
    * @see Chart
    */
    @Override
    protected boolean isClose(PVector point, PVector ref, float dx, float dy) {
        float pointR = point.mag();
        return pointR > minR && pointR < maxR && PVector.angleBetween(ref, point) < dy;
    }
    
    
    /**
    * Aligns text horizontaly and verticaly depending in its position in an circumference.
    * @param angle    The starting angle position of the text
    */
    protected void textAlignPolar(float angle) {
        int h = angle == 0 || angle == PI ? CENTER : angle < PI ? LEFT : RIGHT;
        int v = angle == HALF_PI || angle == 3 * HALF_PI ? CENTER : angle < HALF_PI || angle > 3 * HALF_PI ? BOTTOM : TOP;
        textAlign(h, v);
    }

}



/**
* Radar Charts compare multiple quantitative variables, making them useful for seeing which variables have similar values or if
* there are any outliers amongst each variable. Radar Charts are also useful for seeing which variables are scoring high or low
* within a dataset, making them ideal for displaying performance.
*/
public class RadarChart extends PolarChart {
    
    private int opacity;
    
    
    /**
    * Create a radar chart in polar coordinates
    * @see PolarChart
    * @param opacity       the opacity of dataset polygons
    */
    RadarChart(int TLx, int TLy, int width, int height, int opacity) { //<>//
        super(TLx, TLy, width, height);
        showAxis(true, true);
        this.opacity = opacity;
    }
    
    
    /**
    * Get the position of XY value in chart, overridind the minimum y value (radius) to 0
    * @see Chart
    */
    @Override // Center (minY) to 0
    public PVector getPosition(int x, float y) {
        return new PVector(
            map(x, minX.x, maxX.x+1, limitsMin.x, limitsMax.x),
            map(y, 0, maxY.y, limitsMin.y, limitsMax.y)
        );
    }
    
    
    /**
    * Draw axis if required
    * @see Chart
    */
    protected void drawAxis() {
        pushMatrix();
        translate(center.x, center.y);
        
        if(showAxisX) {
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
        
        if(showAxisY) {
            rotate(-HALF_PI);
            noFill(); stroke(#DDDDDD); strokeWeight(1);
            int vertices = maxX.x - minX.x;
            for(int i = 0; i <= 4; i++) polygon(0, 0, i * maxR / 4, vertices);
        }
        
        popMatrix();
    }
    
    
    /**
    * Draw a dataset
    * @see Chart
    */
    protected void drawDataSet(int setNum, DataSet set, FloatList stack) {
        pushMatrix();
        translate(center.x, center.y);
        rotate(-HALF_PI);
        
        fill(set.COLOR, opacity); stroke(set.COLOR); strokeWeight(1);
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
    
    
    /**
    * Draw a regular polygon with multiple sides and vertices
    * @param x           the center x coordinate of the polygon
    * @param y           the center y coordinate of the polygon
    * @param R           the radius of the polygon
    * @param vertices    the number of vertices
    */
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



/**
* Extensively used in presentations and offices, Pie Charts help show proportions and percentages between categories, by dividing
* a circle into proportional segments. Each arc length represents a proportion of each category, while the full circle represents
* the total sum of all the data, equal to 100%.
*/
public class PieChart extends PolarChart {
    
    private boolean showLabels = true;
    private color holeColor = #FFFFFF;
    
    /**
    * Create a pie chart in polar coordinates
    * @see PolarChart
    */
    public PieChart(int x, int y, int width, int height) {
        super(x, y, width, height);
        limitsMin = new PVector(0, 0);
        limitsMax = new PVector(maxR, TWO_PI);
        stacked = true;
    }
    
    
    /**
    * Create a donut chart in polar coordinates. A donut chart is essentially a Pie Chart with an area of the center cut out.
    * @see PolarChart
    * @param thickness    Thickness of the donut arcs
    */
    public PieChart(int x, int y, int width, int height, float thickness) {
        this(x, y, width, height);
        minR = maxR - thickness;
    }
    
    
    /**
    * Set wheter labels have to be drawn
    * @param labels    Whether labels are displayed
    * @return          the chart itself, simply used for method chaining    
    */
    public Chart showLabels(boolean labels) {
        showLabels = labels;
        return this;
    }
    
    
    /**
    * Calculate min and max boundaries for pie/donut chart, as the total amount of values
    */
    @Override
    protected void calcStackedBounds() {
        float sum = 0;
        int amount = 0;
        for(DataSet set : sets) {
            for(Datum datum : set.data()) {
                sum += datum.y;
                amount++;
            }
        }
        minX = minY = new Datum(0, 0, "MIN");
        maxX = maxY = new Datum(amount, sum, "MAX");
    }
    
    
    /**
    * Draw a dataset
    * @see Chart
    */
    protected void drawDataSet(int setNum, DataSet set, FloatList stack) {
        
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
            
            if( minR > 0 ) drawDot(0, 0, holeColor, int(2 * minR));
            
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
    
    
    /**
    * Override axis drawing function to prevent axis to be drawn
    */
    @Override
    protected void drawAxis() {}

}