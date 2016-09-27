Chart tempLines, tempArea, tempRadar, tempPie;

void setup() {

    size(500, 500, P2D);
    pixelDensity(2);
    
    
    String[] months = new String[] { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" };
    String[] habs = new String[] { "FISICO", "PASE", "DEFENSA", "VELOCIDAD", "DRIBLAJE", "LIDERAZGO", "TACTICA", "TEATRO" };
    
    Set tempMin = new Set("Tmin", "ºC", #3399FF);
    Set tempMax = new Set("Tmin", "ºC", #FF6655);
    Set tempRandom = new Set("Trand", "ºC", #44FF55);
    for(int i = 0; i < 12; i++) {
        tempMin.add( new Datum(i, random(0, 10), months[i]) );
        tempMax.add( new Datum(i, random(10, 20), months[i]) );
        tempRandom.add( new Datum(i, random(0, 20), months[i]) );
    }
    
    tempLines = new Lines(25, 25, 450, 100);
    tempLines.showAxis(true, false);
    tempLines.setDecimals(1);
    //tempLines.threshold("Comfort", 10, 25, color(#FFB347, 100));
    tempLines.add(tempMin, tempMax);
    
    tempArea = new Area(25, 175, 450, 100);
    tempArea.showAxis(true, true);
    tempArea.stacked(true);
    tempArea.setDecimals(1);
    //tempArea.threshold("Comfort", 10, 25, color(#FFB347, 100));
    tempArea.add(tempMin, tempMax);
    
    
    Set pMessi = new Set("Messi", "%", #3399FF);
    Set pCristiano = new Set("Cristiano", "%", #FF6655);
    for(int i = 0; i < 7; i++) {
        pMessi.add( new Datum(i, random(50, 100), habs[i % habs.length]) );
        pCristiano.add( new Datum(i, random(50, 100), habs[i % habs.length]) );
    }
    
    tempRadar = new Radar(25, 300, 175, 175);
    tempRadar.add(pMessi, pCristiano);
    
    
    Set youngPop = new Set("Young", "People", #3399FF);
        youngPop.add( new Datum(3, "<10") );
        youngPop.add( new Datum(6, "10-20") );
        youngPop.add( new Datum(11, "20-30") );
    Set adultPop = new Set("Adult", "People", #FF6655);
        adultPop.add( new Datum(14, "30-45") );
        adultPop.add( new Datum(9, "45-65") );
    Set oldPop = new Set("Elder", "People", #FFB347);
        oldPop.add( new Datum(5, "+65") );
    
    tempPie = new Pie(220, 300, 175, 175, 15);
    tempPie.add(youngPop, adultPop, oldPop);
    
    
}

void draw() {
    
    background(255);
    
    tempLines.draw();
    tempArea.draw();
    tempRadar.draw();
    tempPie.draw();
    
    
}