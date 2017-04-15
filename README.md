# minimalChart

Draw simple and minimalistic charts in Processing, with minimum parameters to customize.

## Features

* Draw Scatter, Lines, Area, Bars, Radar, Pie and Donut charts
* Tooltips to visualize values
* Draw threshold as line or area

## Getting started

Starting a chart is as easy as providing the origin Top-Left corner and size. Some parameters are available.

```
Chart temp = new Lines(50, 50, 300, 100);
temp.showAxis(true, false);
```

Initialization of datums and sets is extremely simple. For datums provide the pair of x,y values and the label. For datasets just provide the name, the units and the color, then add datums as long as they are available.

```
DataSet tMin = new Set("Tmin", "ºC", #3399FF);
DataSet tMax = new Set("Tmax", "ºC", #FF6655);

Datum tNow = new Datum(tMax.size(), 23, "NOV");
Datum hotDaysNOV = new Datum(5, "NOV");  // Used only for PIE and DONUT charts

tMin.add( new Datum(tMin.size(), 19, "NOV") );
tMax.add(tNow);
```

DataSets can be added anytime, alone or in groups. Clear chart every time if you don't want duplicates!!

```
temp.add(tMin);
temp.clear();
temp.add(tMin, tMax);
```

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

## Threshold

A threshold can be added to chart. Threshold has a title and specified color, and can be a line (if you define only one value) or an area (if you define 2 values)

```
alertTemp = new Threshold("Alert", 2, 15, #FF0000);
```

Threshold can be drawn in 2 different ways. First if added to a specific chart, or directly draw it passing specific chart

```
temp.addThreshold(alertTemp);

alertTemp.draw(temp);
```

## Licensing

minimalChart is licensed under MIT license
