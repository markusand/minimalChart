# minimalChart
>Because less is more

Data visualization isn't always a complex task, with tons of customization options. Sometimes you only need a simple chart with a couple of lines.

This small collection of classes is intended to draw very simple and minimalist, although beautiful, charts.

## Getting started

Starting a chart is as easy as providing the origin Top-Left corner and size. Some parameters are available.

```
Chart temp = new LineChart(50, 50, 300, 100);
temp.showAxis(true, false);
```

Initialization of data sets is extremely simple, just provide the name, the unit and the color for each set, then adding values as long as they are available.

```
Set tMin = new Set("Tmin", "ºC", #3399FF);
Set tMax = new Set("Tmax", "ºC", #FF6655);

tMin.add(-5);
tMax.add(27.6);
```

Add a new dataset to chart at anytime

```
temp.add(tMin, tMax);
```

## Features

* Draw Dots, Lines and Area charts
* Tooltips to visualize values

## Configuration

Some parameters are available to customize the chart

#### showAxis(boolean xAxis, boolean yAxis)
Type: `boolean`  
Default: `'false'`

Define if horizontal and vertical axis are shown

#### decimals(int dec)
Type: `int`  
Default: 1

Define number of decimals are shown in labels and axis

## Contributing

If you'd like to contribute, please fork the repository and use a feature
branch. Pull requests are warmly welcome.

Keep in mind the main idea is to keep it as minimal and simple as possible!

## Licensing

minimalChart is licensed under MIT license