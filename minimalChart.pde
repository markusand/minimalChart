Chart tempLines, tempArea, tempRadar;
Set tempMin, tempMax, tempRandom; 

void setup() {

    size(500, 500, FX2D);
    pixelDensity(2);
    
    tempMin = new Set("Tmin", "ºC", #3399FF);
    tempMax = new Set("Tmin", "ºC", #FF6655);
    tempRandom = new Set("Trand", "ºC", #44FF55);
    
    for(int i = 0; i < 10; i++) {
        tempMin.add( random(0, 15) );
        tempMax.add( random(15, 30) );
        tempRandom.add( random(0, 10) );
    }
    
    
    tempLines = new LineChart(25, 25, 450, 100);
    tempLines.showAxis(true, false);
    tempLines.decimals(1);
    
    tempArea = new AreaChart(25, 175, 450, 100);
    tempArea.showAxis(true, true);
    tempArea.stacked(true);
    tempArea.decimals(1);
    
    tempRadar = new RadarChart(25, 25, width-50, height-50);
    tempRadar.showAxis(true, true);
    tempRadar.decimals(2);
    tempRadar.stacked(true);
    
    //tempLines.threshold("Comfort", 10, 25, color(#FFB347, 100));
    //tempArea.threshold("Comfort", 10, 25, color(#FFB347, 100));
    
    tempLines.add(tempMin, tempMax);
    tempArea.add(tempMax, tempRandom);
    tempRadar.add(tempMin, tempRandom, tempMax);
    
}

void draw() {
    
    background(255);
    
    //tempLines.draw();
    //tempArea.draw();
    tempRadar.draw();
    
}