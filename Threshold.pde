/**
* Define a range of values that are used as a basis for comparison
*/
protected class Threshold {
    
    private final String NAME;
    private final float MIN;
    private final float MAX;
    private final color COLOR;
    
    private int opacity = 70;
    
    
    /**
    * Create a line threshold
    * @param name    the label name of threshold
    * @param value   the value of the threshold
    * @param tint    the color of the threshold
    */
    Threshold(String name, float value, color tint) {
        this(name, value, value, tint);
    }
    
    
    /**
    * Create an area threshold
    * @param name    the label name of threshold
    * @param min     the min value of the threshold
    * @param max     the max value of the threshold
    * @param tint    the color of the threshold
    */
    Threshold(String name, float min, float max, color tint) {
        NAME = name;
        MIN = min(min, max);    // Prevent swapped min and max values
        MAX = max(min, max);    //
        COLOR = tint;
    }
    
    
    /**
    * Draw the threshold in a specific chart
    * @param chart    the chart to draw the threshold in
    */
    public void draw(Chart chart) {
        if(MAX >= chart.minY.y && MIN <= chart.maxY.y) {  // Threshold inside chart bounds 
            pushMatrix();
            translate(chart.TL.x, chart.TL.y);
            PVector minPos = chart.getPosition(chart.minX.x, constrain(MIN, chart.minY.y, chart.maxY.y));
            if( MIN == MAX ) {
                stroke(COLOR); strokeWeight(1);
                line(0, minPos.y, chart.SIZE.x, minPos.y);
            } else {
                PVector maxPos = chart.getPosition(chart.maxX.x, constrain(MAX, chart.minY.y, chart.maxY.y));
                fill(COLOR, opacity); noStroke(); rectMode(CORNERS);
                rect(minPos.x, minPos.y, maxPos.x, maxPos.y);
            }
            fill(COLOR); textAlign(LEFT, BOTTOM);
            text(NAME, 3, minPos.y);
            popMatrix();
        }
    }
    
}