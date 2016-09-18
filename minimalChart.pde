Chart tempLines, tempArea, tempRadar;
Set tempMin, tempMax, tempRandom; 

void setup() {

    size(500, 500, P2D);
    pixelDensity(2);
    
    
    tempMin = new Set("Tmin", "ºC", #3399FF);
    tempMax = new Set("Tmin", "ºC", #FF6655);
    tempRandom = new Set("Trand", "ºC", #44FF55);
    
    for(int i = 0; i < 10; i++) {
        tempMin.add( new Datum(i, random(0, 10), "Min"+i) );
        tempMax.add( new Datum(i, random(10, 20), "Max"+i) );
        tempRandom.add( new Datum(i, random(0, 20), "Rand"+i) );
    }
    
    tempLines = new Lines(25, 25, 450, 100);
    tempLines.showAxis(true, false);
    tempLines.setDecimals(1);
    
    
    tempArea = new Lines(25, 175, 450, 100);
    tempArea.showAxis(true, true);
    tempArea.stacked(true);
    tempArea.setDecimals(1);
    
    //tempRadar = new Lines(25, 25, width-50, height-50);
    //tempRadar.showAxis(true, true);
    //tempRadar.setDecimals(2);
    //tempRadar.stacked(true);
    
    //tempLines.threshold("Comfort", 10, 25, color(#FFB347, 100));
    //tempArea.threshold("Comfort", 10, 25, color(#FFB347, 100));
    
    
    tempLines.add(tempMin, tempMax);
    tempArea.add(tempMin, tempMax);
    //tempRadar.add(tempMin, tempRandom, tempMax);
    
    
}

void draw() {
    
    background(255);
    
    tempLines.draw();
    tempArea.draw();
    //tempRadar.draw();
    
    
}