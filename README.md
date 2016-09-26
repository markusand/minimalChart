# minimalChart

Draw simple and minimalistic charts in Processing, with minimum parameters to customize.

## Getting started

Starting a chart is as easy as providing the origin Top-Left corner and size. Some parameters are available.

```
Chart temp = new Lines(50, 50, 300, 100);
temp.showAxis(true, false);
```

Initialization of datums and sets is extremely simple. For datums provide de the pair of x,y values and the label. For datasets just provide the name, the units and the color, then add datums as long as they are available.

```
Set tMin = new Set("Tmin", "ºC", #3399FF);
Set tMax = new Set("Tmax", "ºC", #FF6655);

Datum tNow = new Datum(tMax.size(), 23, "15h30");
Datum hotDaysNOV = new Datum(5, "NOV");  // Used only for PIE and DONUT charts

tMin.add( new Datum(tMin.size(), 19, "15h30") );
tMax.add(tNow);
```

Sets can be added anytime, alone or in groups. Clear chart every time if you don't want duplicates!!

```
temp.add(tMin);
temp.clear();
temp.add(tMin, tMax);
```

## Features

* Draw Scatter, Lines, Area, Radar, Pie and Donut charts
* Tooltips to visualize values
* Draw threshold as line or area

## Configuration

Some parameters are available to customize the chart

#### stacked(stacked);
Type: `boolean`  
Default: `'false'`

Every dataset is stacked over previous

#### showAxis(xAxis, yAxis);
Type: `boolean`  
Default: `'false', 'false'`

Display horizontal and vertical axis

#### setDecimals(decimals);
Type: `int`  
Default: 0

Set number of decimals to show in tooltips and axis

#### setThreshold(name, min [, max], color);
Type: `String, float, float, color`  

Add threshold to graph. It can be a line or an area

## Licensing

minimalChart is licensed under MIT license