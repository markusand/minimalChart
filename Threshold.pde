protected class Threshold {
    
    private final Chart CHART;
    private final String NAME;
    private final float MIN;
    private final float MAX;
    private final color COLOR;
    
    private int opacity = 70;
    
    Threshold(Chart chart, String name, float min, float max, color tint) {
        CHART = chart;
        NAME = name;
        if(min < max) {
            MIN = min;
            MAX = max;
        } else {
            MIN = max;
            MAX = min;
        }
        COLOR = tint;
    }
    
    public void draw() {
        if(MAX >= CHART.minY.y && MIN <= CHART.maxY.y) {  // Threshold inside chart bounds 
            PVector minPos = CHART.getPosition(CHART.minX.x, constrain(MIN, CHART.minY.y, CHART.maxY.y));
            if( MIN == MAX ) {
                stroke(COLOR); strokeWeight(1);
                line(0, minPos.y, CHART.SIZE.x, minPos.y);
            } else {
                PVector maxPos = CHART.getPosition(CHART.maxX.x, constrain(MAX, CHART.minY.y, CHART.maxY.y));
                fill(COLOR, opacity); noStroke(); rectMode(CORNERS);
                rect(minPos.x, minPos.y, maxPos.x, maxPos.y);
            }
            fill(COLOR); textAlign(LEFT, BOTTOM);
            text(NAME, 3, minPos.y);
        }
    }
    
}