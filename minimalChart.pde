Chart tempLines, tempArea;
Set tempMin, tempMax; 

void setup() {

    size(500, 300, FX2D);
    pixelDensity(2);
    
    tempMin = new Set("Tmin", "ºC", #3399FF);
    tempMax = new Set("Tmin", "ºC", #FF6655);
    
    for(int i = 0; i < 20; i++) {
        tempMin.add( random(0, 15) );
        tempMax.add( random(15, 30) );
    }
    
    
    tempLines = new LineChart(25, 25, 450, 100);
    tempLines.showAxis(true, false);
    tempLines.decimals(1);
    
    tempArea = new AreaChart(25, 175, 450, 100);
    tempArea.showAxis(true, true);
    tempArea.stacked(true);
    tempArea.decimals(1);
    
    tempLines.threshold("Comfort", 10, 25, color(#FFB347, 100));
    tempArea.threshold("Comfort", 10, 25, color(#FFB347, 100));
    
    tempLines.add(tempMin, tempMax);
    tempArea.add(tempMin, tempMax);
    
}

void draw() {
    
    background(255);
    
    tempLines.draw();
    tempArea.draw();
    
}