import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

// The Targets Class.
@immutable
class Targets {
  const Targets(this.name, this.size);
  /// The name of the Day.
  final String name;
  /// The size of investment.
  final int size;
}
List<Targets> generateWeekData(){
  List<Targets> generator = List();
  List<int> data = [15, 12, 6, 27, 20, 13, 28]; //can be assigned via API 
  for(int i=0; i<7; ++i){
    switch (i) {
      case 0: generator.add(Targets("Sun",data[i]));
        break;
      case 1: generator.add(Targets("Mon",data[i]));
        break;
      case 2: generator.add(Targets("Tue",data[i]));
        break;
      case 3: generator.add(Targets("Wed",data[i]));
        break;
      case 4: generator.add(Targets("Thu",data[i]));
        break;
      case 5: generator.add(Targets("Fri",data[i]));
        break;
      case 6: generator.add(Targets("Sat",data[i]));
        break;
      default:
        break;
    }
  }
  return generator;
}
/// Our targets data.
List<Targets> targets = generateWeekData();

class TargetsLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // setting x-axis here
    final xAxis = new ChartAxis<String>(
      hideLine: false,
      tickLabelerStyle: new TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,height: 2.0,
      ),
      paint: const PaintOptions.stroke(color: Colors.white, strokeWidth: 1.5),
    );
    // setting y-axis here
    final yAxis = new ChartAxis(
      hideLine: true,
      span: new IntSpan(0, 30),
      opposite: false,
      tickGenerator: IntervalTickGenerator.byN(10),
      paint: const PaintOptions.stroke(color: Colors.transparent),
      hideTickNotch: true,
      tickLabelerStyle: new TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );

    return new LineChart(
      chartPadding: new EdgeInsets.fromLTRB(30.0, 20.0, 20.0, 40.0),
      lines: [
        // size line
        new Line<Targets, String, int>(
          data: targets,
          xFn: (target) => target.name,
          yFn: (target) => target.size,
          xAxis: xAxis,
          yAxis: yAxis,
          marker: const MarkerOptions(
              paint: const PaintOptions.fill(color: Colors.white),
              shape: MarkerShapes.circle,
              size: 5.0),
          stroke:
              const PaintOptions.stroke(color: Colors.white, strokeWidth: 2.0),
        ),
      ],
    );
  }
}
