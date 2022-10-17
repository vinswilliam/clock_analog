import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  static const String routeName = '/secondPage';

  const SecondPage({Key? key, required this.payload}) : super(key: key);

  final String payload;

  @override
  _SecondPageState createState() {
    return _SecondPageState();
  }
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    // int hour = int.parse(widget.payload) ~/ 60;
    // int minute = int.parse(widget.payload) % 60;
    // String alarmSet = '$hour : $minute';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bar Chart'),
      ),
      body: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Alarm set ${widget.payload}',
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  width: double.infinity,
                  child: BarChart(
                    randomData(),
                  ),
                ),
              )
            ],
          )),
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        return makeGroupData(0, 5);
      });

  BarChartData randomData() {
    return BarChartData(
      // maxY: 60,
      barTouchData: BarTouchData(
        enabled: false,
      ),
      // titlesData: FlTitlesData(
      //   bottomTitles: AxisTitles(
      //       sideTitles:
      //           SideTitles(showTitles: true, getTitlesWidget: getTitles)),
      //   leftTitles: AxisTitles(
      //       sideTitles:
      //           SideTitles(showTitles: false)),
      //   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      //   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      // ),
      barGroups: showingGroups(),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(show: true),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    double width = 22,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: 10,
          color: Colors.blue,
          width: width,
        ),
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    Widget text = const Text('Date', style: style);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }
}
