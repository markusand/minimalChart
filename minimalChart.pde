Chart tempLines, tempArea, tempPie;

void setup() {

    size(500, 500, P2D);
    pixelDensity(2);
    
    
    Set tempMin = new Set("Tmin", "ºC", #3399FF);
    Set tempMax = new Set("Tmin", "ºC", #FF6655);
    Set tempRandom = new Set("Trand", "ºC", #44FF55);
    for(int i = 0; i < 10; i++) {
        tempMin.add( new Datum(i, random(0, 10), "Min"+i) );
        tempMax.add( new Datum(i, random(10, 20), "Max"+i) );
        tempRandom.add( new Datum(i, random(0, 20), "Rand"+i) );
    }
    
    tempLines = new Lines(25, 25, 450, 100);
    tempLines.showAxis(true, false);
    tempLines.setDecimals(1);
    //tempLines.threshold("Comfort", 10, 25, color(#FFB347, 100));
    tempLines.add(tempMin, tempMax);
    
    tempArea = new Lines(25, 175, 450, 100);
    tempArea.showAxis(true, true);
    tempArea.stacked(true);
    tempArea.setDecimals(1);
    //tempArea.threshold("Comfort", 10, 25, color(#FFB347, 100));
    tempArea.add(tempMin, tempMax);
    
    Set youngPop = new Set("Young", "People", #44FF55);
        youngPop.add( new Datum(3, "<10") );
    Set adultPop = new Set("Adult", "People", #3399FF);
        adultPop.add( new Datum(5, "30-40") );
    
    tempPie = new Pie(25, 25, width-50, height-50);
    tempPie.add(tempMin, tempMax);
    
    
}

void draw() {
    
    background(255);
    
    //tempLines.draw();
    //tempArea.draw();
    tempPie.draw();
    
    
}