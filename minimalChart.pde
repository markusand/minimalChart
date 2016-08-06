Chart tempLines, tempArea;
Set tempMin, tempMax; 

void setup() {

    size(500, 300, FX2D);
    pixelDensity(2);
    
    tempMin = new Set("Tmin", "ºC", #3399FF);
    for(int i = 0; i < 20; i++) {
        tempMin.add( random(-10, 10) );
    }
    
    tempMax = new Set("Tmin", "ºC", #FF6655);
    for(int i = 0; i < 20; i++) {
        tempMax.add( random(-10, 10) );
    }
    
    tempLines = new LineChart(25, 25, 450, 100);
    tempLines.showAxis(false, true);
    tempLines.decimals(1);
    
    tempArea = new AreaChart(25, 175, 450, 100);
    tempArea.showAxis(true, false);
    tempArea.decimals(1);
    
    tempLines.add(tempMin, tempMax);
    tempArea.add(tempMin, tempMax);
    
}

void draw() {
    
    background(255);
    
    tempLines.draw();
    tempArea.draw();
    
}