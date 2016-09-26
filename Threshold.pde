protected class Threshold {
    
    private Chart chart;
    private String name;
    private float min;
    private float max;
    private color tint;
    
    Threshold(Chart chart, String name, float min, float max, color tint) {
        this.chart = chart;
        this.name = name;
        if(min < max) {
            this.min = min;
            this.max = max;
        } else {
            this.min = max;
            this.max = min;
        }
        this.tint = tint;
    }
    
    protected void draw() {
        if(max >= chart.minY.y && min <= chart.maxY.y) {
            PVector minPos = chart.getPosition(0, min > chart.minY.y ? min : chart.minY.y);
            if( min == max ) {
                stroke(tint); strokeWeight(1);
                line(0, minPos.y, chart.size.x, minPos.y);
            } else {
                PVector maxPos = chart.getPosition(chart.maxX.x, max < chart.maxY.y ? max : chart.maxY.y);
                fill(tint, 70); noStroke(); rectMode(CORNERS);
                rect(minPos.x, minPos.y, maxPos.x, maxPos.y);
            }
            fill(tint); textAlign(LEFT, BOTTOM);
            text(name, 3, minPos.y);
        }
    }
    
}


protected class RThreshold extends Threshold {
    
    RThreshold(Chart chart, String name, float min, float max, color tint) {
        super(chart, name, min, max, tint);
    }
    
    @Override
    protected void draw() {
    }
    
}