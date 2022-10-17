
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

    return Container(
        decoration: const BoxDecoration(color: Colors.white),
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text('Alarm set ${widget.payload}'),
            BarChart(
              randomData(),
              swapAnimationDuration: const Duration(milliseconds: 150), // Optional
              swapAnimationCurve: Curves.linear, // Optional
            )
          ],
        ));
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
            sideTitles:
                SideTitles(showTitles: true, getTitlesWidget: getTitles)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: false,
      ),
    );
  }

   BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? Colors.yellow : barColor,
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.yellow)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: Colors.blue,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    Widget text = const Text('M', style: style);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }
}
