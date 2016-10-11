Chart tempLines, tempArea, tempBars, tempBarsStacked, charsRadar, agesPie;

void setup() {

    size(975, 500, P2D);
    pixelDensity(2);
    
    String[] months = new String[] { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" };
    
    Set tempMin = new Set("Tmin", "ºC", #3399FF);
    Set tempMax = new Set("Tmin", "ºC", #FF6655);
    Set tempRand = new Set("Trand", "ºC", #FFB347); 
    for(int i = 0; i < 12; i++) {
        tempMin.add( new Datum(i, random(0, 15), months[i % months.length]) );
        tempMax.add( new Datum(i, random(15, 30), months[i % months.length]) );
        tempRand.add( new Datum(i, random(0, 30), months[i % months.length]) );
    }
    
    tempLines = new Lines(25, 25, 450, 100);
    tempLines.showAxis(true, false).setDecimals(1);
    //tempLines.addThreshold("Comfort", 17, 25, color(#FFB347, 200));
    //tempLines.addThreshold("Alert", 5, #FF0000);
    tempLines.add(tempMin, tempMax, tempRand);
    
    tempArea = new Area(25, 175, 450, 100);
    tempArea.stacked(true).showAxis(true, true).setDecimals(1);
    tempArea.add(tempMin, tempMax);
    
    tempBars = new Bars(500, 25, 450, 100);
    tempBars.showAxis(true, true).setDecimals(1);
    tempBars.add(tempMin, tempMax, tempRand);
    
    tempBarsStacked = new Bars(500, 175, 450, 100);
    tempBarsStacked.showAxis(true, true).setDecimals(1).stacked(true);
    tempBarsStacked.add(tempMin, tempMax, tempRand);
    
    String[] habs = new String[] { "FISICO", "PASE", "DEFENSA", "VELOCIDAD", "DRIBLAJE", "LIDERAZGO", "TACTICA", "TEATRO" };
    
    Set pMessi = new Set("Messi", "%", #3399FF);
    Set pCristiano = new Set("Cristiano", "%", #FF6655);
    for(int i = 0; i < 6; i++) {
        pMessi.add( new Datum(i, random(50, 100), habs[i % habs.length]) );
        pCristiano.add( new Datum(i, random(50, 100), habs[i % habs.length]) );
    }
    
    charsRadar = new Radar(50, 300, 175, 175);
    charsRadar.add(pMessi, pCristiano);
    
    
    Set youngPop = new Set("Young", "People", #3399FF);
        youngPop.add( new Datum(3, "<10") );
        youngPop.add( new Datum(6, "10-20") );
        youngPop.add( new Datum(11, "20-30") );
    Set adultPop = new Set("Adult", "People", #FF6655);
        adultPop.add( new Datum(14, "30-45") );
        adultPop.add( new Datum(9, "45-65") );
    Set oldPop = new Set("Elder", "People", #FFB347);
        oldPop.add( new Datum(5, "+65") );
    
    agesPie = new Pie(275, 325, 175, 125, 40);
    agesPie.add(youngPop, adultPop, oldPop);
    
    
}

void draw() {
    
    background(255);
    
    tempLines.draw();
    tempArea.draw();
    charsRadar.draw();
    agesPie.draw();
    tempBars.draw();
    tempBarsStacked.draw();
    
}