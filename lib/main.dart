import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' hide TextDirection;

void main() {
  runApp(new ChartDemo());
}

class ChartDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var s = new Scaffold(
      body: new Center(child: new CustomPaint(
        size: new Size(350.0, 400.0),
        painter: new LineChart<DateTime, double>(createChartData()),
    )));

    return new MaterialApp(
      title: 'Chart demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: s,
    );
  }

  DateTime removeTime(DateTime d) {
    var removeTimeFormatter = new DateFormat('MM-dd-yyyy');
    return removeTimeFormatter.parse(removeTimeFormatter.format(d));
  }

  LineChartMetadata<DateTime, double> createChartData() {
    DateFormat dateFormatter = new DateFormat('yyyy-MM-dd');

    var f = new NumberFormat("###.0");

    var formatter = new DateFormat('MM-dd');
    Converter<double> doubleConverter = (v) => v;
    Converter<DateTime> dateConverter = (v) => removeTime(v).millisecondsSinceEpoch.toDouble();
    StringConverter doubleLabelConverter = (v) => f.format(v);
    StringConverter dateLabelConverter = (v) => formatter.format(removeTime(new DateTime.fromMillisecondsSinceEpoch(v.toInt(), isUtc: false)));

    var now = new DateTime.now();

    List<ChartData<DateTime, double>> chartData = [
      new ChartData(now, 0.0),
      new ChartData(now.add(new Duration(days: 1)), 0.0),
      new ChartData(now.add(new Duration(days: 5)), 4.0),
      new ChartData(now.add(new Duration(days: 6)), -3.0),
      new ChartData(now.add(new Duration(days: 7)), 2.0),
      new ChartData(now.add(new Duration(days: 11)), 10.0),
      new ChartData(now.add(new Duration(days: 20)), 20.0),
      new ChartData(now.add(new Duration(days: 21)), 5.0)
    ];
    var rangeLabelSteps = <double>[1.0, .5, .1, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0];

    var dayLength = dateConverter(now) - dateConverter(now.subtract(new Duration(days: 1)));
    var domainLabelSteps = <double>[dayLength, dayLength * 2.0, dayLength * 3.0, dayLength * 5.0, dayLength * 7.0, dayLength * 10.0, dayLength * 30.0, dayLength * 60.0, dayLength * 365.0];

    var metadata = new LineChartMetadata(chartData, dateConverter, doubleConverter, dateLabelConverter, doubleLabelConverter, 5, domainLabelSteps, 15, rangeLabelSteps);
    return metadata;
  }
}


class ChartData<D, R> {
  ChartData(this.domain, this.range);

  R range;
  D domain;
}

typedef double Converter<T>(T value);
typedef String StringConverter(double value);

class LineChartMetadata<D, R> {
  List<ChartData<D, R>> values;
  double minX;
  double maxX;
  double minY;
  double maxY;
  double xRange;
  double yRange;
  Converter<D> domainConverter;
  Converter<R> rangeConverter;
  List<double> rangeAxisLabels;
  List<double> domainAxisLabels;
  StringConverter domainLabelConverter;
  StringConverter rangeLabelConverter;

  LineChartMetadata(this.values, this.domainConverter, this.rangeConverter, this.domainLabelConverter, this.rangeLabelConverter,
      int preferredDomainLabelCount, List<double> domainLabelSteps, int preferredRangeLabelCount, List<double> rangeLabelSteps) {

    if (values.length > 0) {
      minX = domainConverter(values[0].domain);
      minY = rangeConverter(values[0].range);
      maxX = domainConverter(values[0].domain);
      maxY = rangeConverter(values[0].range);
      for (int i=1; i<values.length; i++) {
        var x = domainConverter(values[i].domain);
        var y = rangeConverter(values[i].range);
        if (x < minX) {
          minX = x;
        }
        if (x > maxX) {
          maxX = x;
        }
        if (y < minY) {
          minY = y;
        }
        if (y > maxY) {
          maxY = y;
        }
      }
      xRange = maxX - minX;
      yRange = maxY - minY;
    } else {
      minX = 0.0;
      minY = 0.0;
      maxX = 1.0;
      maxY = 1.0;
      xRange = maxX - minX;
      yRange = maxY - minY;
    }

    getRangeLabels(rangeLabelSteps, preferredRangeLabelCount);
    getDomainLabels(domainLabelSteps, preferredDomainLabelCount);
  }

  void getRangeLabels(List<double> rangeLabelSteps, int preferredRangeLabelCount) {
    int bestMatchIndex = 0;
    int bestLabelCount = ((yRange / rangeLabelSteps[0]).round() - preferredRangeLabelCount).abs();
    for (int i=1; i<rangeLabelSteps.length; i++) {
      var labelCount = ((yRange / rangeLabelSteps[i]).round() - preferredRangeLabelCount).abs();
      if (labelCount < bestLabelCount) {
        bestLabelCount = labelCount;
        bestMatchIndex = i;
      }
    }

    double startLabel = (minY / rangeLabelSteps[bestMatchIndex]).floor() * rangeLabelSteps[bestMatchIndex];
    if (startLabel < minY) {
      startLabel += rangeLabelSteps[bestMatchIndex];
    }
    double endLabel = (maxY / rangeLabelSteps[bestMatchIndex]).ceil() * rangeLabelSteps[bestMatchIndex];
    if (endLabel > maxY) {
      endLabel -= rangeLabelSteps[bestMatchIndex];
    }

    rangeAxisLabels = <double>[];
    for (double labelPos = startLabel; labelPos <= endLabel; labelPos += rangeLabelSteps[bestMatchIndex]) {
      rangeAxisLabels.add(labelPos);
    }
  }

  void getDomainLabels(List<double> labelSteps, int preferredLabelCount) {
    int bestMatchIndex = 0;
    int bestLabelCount = ((xRange / labelSteps[0]).round() - preferredLabelCount).abs();
    for (int i=1; i<labelSteps.length; i++) {
      var labelCount = ((xRange / labelSteps[i]).round() - preferredLabelCount).abs();
      if (labelCount < bestLabelCount) {
        bestLabelCount = labelCount;
        bestMatchIndex = i;
      }
    }

    double startLabel = (minX / labelSteps[bestMatchIndex]).floor() * labelSteps[bestMatchIndex];
    if (startLabel < minX) {
      startLabel += labelSteps[bestMatchIndex];
    }
    double endLabel = (maxX / labelSteps[bestMatchIndex]).ceil() * labelSteps[bestMatchIndex];
    if (endLabel > maxX) {
      endLabel -= labelSteps[bestMatchIndex];
    }

    domainAxisLabels = <double>[];
    for (double labelPos = startLabel; labelPos <= endLabel; labelPos += labelSteps[bestMatchIndex]) {
      domainAxisLabels.add(labelPos);
    }
  }

  double rangeToScreen(double ySize, R value) {
    var y =  (rangeConverter(value) - minY) / yRange * ySize;
    return ySize - y;
  }

  double yToScreen(double ySize, double y) {
    var y2 =  (y - minY) / yRange * ySize;
    return ySize - y2;
  }

  double domainToScreen(double xSize, D value) {
    var x = (domainConverter(value)- minX) / xRange * xSize;
    return x;
  }

  double xToScreen(double xSize, double x) {
    var x2 = (x - minX) / xRange * xSize;
    return x2;
  }

  Offset chartDataToScreen(double xSize, double ySize, ChartData<D, R> point) {
    var x = domainToScreen(xSize, point.domain);
    var y = rangeToScreen(ySize, point.range);
    return new Offset(x, y);
  }
}

class LineChart<D, R> extends CustomPainter {
  LineChartMetadata<D, R> metadata;
  double rangeAxisWidth = .15;
  double domainAxisHeight = .1;

  LineChart(this.metadata);

  @override
  void paint(Canvas canvas, Size size) {
    var linePainter = new LinePainter(metadata);
    canvas.translate(size.width * rangeAxisWidth, 0.0);
    linePainter.paint(canvas, new Size(size.width * (1.0 - rangeAxisWidth), size.height * (1.0 - domainAxisHeight)));
    var highlightPointPainter = new HighlightPointPainter(metadata);
    highlightPointPainter.paint(canvas, new Size(size.width * (1.0 - rangeAxisWidth), size.height * (1.0 - domainAxisHeight)));

    canvas.translate(-size.width * rangeAxisWidth, 0.0);

    var axisLabelPainter = new RangeAxisLabelPainter(metadata);
    axisLabelPainter.paint(canvas, new Size(size.width * rangeAxisWidth, size.height * (1.0 - domainAxisHeight)));

    canvas.translate(size.width * rangeAxisWidth, size.height * (1.0 - domainAxisHeight));
    var domainAxisLabelPainter = new DomainAxisLabelPainter(metadata);
    domainAxisLabelPainter.paint(canvas, new Size(size.width * (1.0 - rangeAxisWidth), size.height * domainAxisHeight));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class LinePainter<D, R> extends CustomPainter {
  LineChartMetadata<D, R> metadata;

  LinePainter(this.metadata);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = new Paint()
      ..strokeWidth = 2.0
      ..color = Colors.blue[400]
      ..style = PaintingStyle.fill;

    var p1 = new Offset(0.0, 0.0);
    var p2 = metadata.chartDataToScreen(size.width, size.height, metadata.values[0]);

    for (int i=1; i<metadata.values.length; i++) {
      p1 = p2;
      p2 = metadata.chartDataToScreen(size.width, size.height, metadata.values[i]);
      canvas.drawLine(p1, p2, paint);
    }

    final blackPaint = new Paint()
      ..strokeWidth = 1.0
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawLine(new Offset(0.0, 0.0), new Offset(0.0, size.height), blackPaint);
    canvas.drawLine(new Offset(0.0, size.height), new Offset(size.width, size.height), blackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HighlightPointPainter<D, R> extends CustomPainter {
  LineChartMetadata<D, R> metadata;

  HighlightPointPainter(this.metadata);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = new Paint()
      ..strokeWidth = 1.0
      ..color = new Color.fromRGBO(Colors.red[400].red, Colors.red[400].green, Colors.red[400].blue, .5)
      ..style = PaintingStyle.fill;
    var p = new Offset(0.0, 0.0);

    for (int i=0; i<metadata.values.length; i++) {
      p = metadata.chartDataToScreen(size.width, size.height, metadata.values[i]);
      canvas.drawCircle(p, 4.0, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


class RangeAxisLabelPainter<D, R> extends CustomPainter {
  LineChartMetadata<D, R> metadata;

  TextPainter labelPainter = new TextPainter(textDirection: TextDirection.ltr);
//  TextPainter labelPainter = new TextPainter();

  RangeAxisLabelPainter(this.metadata);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i=0; i<metadata.rangeAxisLabels.length; i++) {
      labelPainter.text = new TextSpan(
        text: metadata.rangeLabelConverter(metadata.rangeAxisLabels[i]),
        style: new TextStyle(color: Colors.black),
      );
      labelPainter.layout();
      var y = metadata.yToScreen(size.height, metadata.rangeAxisLabels[i]);
      labelPainter.paint(canvas, new Offset(0.0, y - labelPainter.height / 2.0));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DomainAxisLabelPainter<D, R> extends CustomPainter {
  LineChartMetadata<D, R> metadata;

  TextPainter labelPainter = new TextPainter(textDirection: TextDirection.ltr);
//  TextPainter labelPainter = new TextPainter();

  DomainAxisLabelPainter(this.metadata);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i=0; i<metadata.domainAxisLabels.length; i++) {
      labelPainter.text = new TextSpan(
        text: metadata.domainLabelConverter(metadata.domainAxisLabels[i]),
        style: new TextStyle(color: Colors.black),
      );
      labelPainter.layout();
      var x = metadata.xToScreen(size.width, metadata.domainAxisLabels[i]);
      // TODO fix
//      labelPainter.paint(canvas, new Offset(x - labelPainter.width / 2.0, 5.0));
      labelPainter.paint(canvas, new Offset(x, 5.0));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}