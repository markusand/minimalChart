private class Threshold {

    private String name;
    private float min, max;
    private color tint;
    
    Threshold(String name, float min, float max, color tint) {
        this.name = name;
        this.min = min;
        this.max = max;
        this.tint = tint;
    }
    
    protected void draw(Chart chart) {
        
        /*
        float posMin = min(chart.BR.y, chart.getPos(min));
        float posMax = min != max ? max(chart.TL.y, chart.getPos(max)) : posMin;
        
        fill(tint, 100); stroke(tint); strokeWeight(1); rectMode(CORNERS);
        rect(chart.TL.x, posMin, chart.BR.x, posMax);
        
        fill(tint); textAlign(LEFT, BOTTOM);
        text(name, chart.TL.x + 3, posMin);
        */
    }
    
}