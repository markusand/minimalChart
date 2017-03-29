/*
* Copyright (c) 2016, Marc Vilella. All rights reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/


Chart tempLines, tempArea, tempBars, tempBarsStacked, playersRadar, agesPie;
DataSet tempMin, tempMax, tempRand;
Threshold threshold;

void setup() {

    size(975, 500, P2D);
    pixelDensity(2);
    
    
    String[] months = new String[] { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" };
    
    threshold = new Threshold("Alert", 2, 15, #FF0000);
    
    tempMin = new DataSet("Tmin", "ºC", #3399FF);
    tempMax = new DataSet("Tmin", "ºC", #FF6655);
    tempRand = new DataSet("Trand", "ºC", #FFB347); 
    for(int i = 0; i < 12; i++) {
        tempMin.add( new Datum(i, random(0, 15), months[i % months.length]) );
        tempMax.add( new Datum(i, random(15, 30), months[i % months.length]) );
        tempRand.add( new Datum(i, random(0, 30), months[i % months.length]) );
    }
    
    tempLines = new LineChart(25, 25, 450, 100, 5, 1);
    tempLines.showAxis(true, false).setDecimals(1);
    tempLines.addThreshold(threshold);
    tempLines.add(tempMin, tempMax, tempRand);
    
    tempArea = new AreaChart(25, 175, 450, 100, 70);
    tempArea.stacked(true).showAxis(true, true).setDecimals(1);
    tempArea.add(tempMin, tempMax, tempRand);
    
    tempBars = new BarChart(500, 25, 450, 100);
    tempBars.showAxis(true, true).setDecimals(1);
    tempBars.add(tempMin, tempMax, tempRand);
    
    tempBarsStacked = new BarChart(500, 175, 450, 100);
    tempBarsStacked.showAxis(true, true).setDecimals(1).stacked(true);
    tempBarsStacked.add(tempMin, tempMax, tempRand);
    
    String[] habs = new String[] { "FISICO", "PASE", "DEFENSA", "VELOCIDAD", "DRIBLAJE", "LIDERAZGO", "TACTICA", "TEATRO" };
    DataSet pMessi = new DataSet("Messi", "%", #3399FF);
    DataSet pCristiano = new DataSet("Cristiano", "%", #FF6655);
    for(int i = 0; i < habs.length; i++) {
        pMessi.add( new Datum(i, random(50, 100), habs[i]) );
        pCristiano.add( new Datum(i, random(50, 100), habs[i]) );
    }
    
    playersRadar = new RadarChart(50, 300, 175, 175, 70);
    playersRadar.add(pMessi, pCristiano);
    
    
    DataSet youngPop = new DataSet("Young", "People", #3399FF);
        youngPop.add( new Datum(3, "<10") );
        youngPop.add( new Datum(6, "10-20") );
        youngPop.add( new Datum(11, "20-30") );
    DataSet adultPop = new DataSet("Adult", "People", #FF6655);
        adultPop.add( new Datum(14, "30-45") );
        adultPop.add( new Datum(9, "45-65") );
    DataSet oldPop = new DataSet("Elder", "People", #FFB347);
        oldPop.add( new Datum(5, "+65") );
    
    agesPie = new PieChart(275, 325, 175, 125, 40);
    agesPie.add(youngPop, adultPop, oldPop);
    
}

void draw() {
    
    background(255);
    
    tempLines.draw();
    tempArea.draw();
    playersRadar.draw();
    agesPie.draw();
    tempBars.draw();
    tempBarsStacked.draw();
    
    //threshold.draw(tempBars);
    
}


void mouseClicked() {
    
    tempMin.add( new Datum(tempMin.size(), random(0, 50), "random") );
    tempMax.add( new Datum(tempMax.size(), random(0, 50), "random") );
    tempRand.add( new Datum(tempRand.size(), random(0, 50), "random") );
    
    tempLines.update();
    tempArea.update();
    tempBars.update();
    tempBarsStacked.update();
    
}