import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectta/model/chart_data.dart';
import 'package:projectta/model/tambak.dart';
import 'package:projectta/model/weekly_settings.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeeklyPage extends StatefulWidget {
  final WeeklySettings settings;
  final Tambak tambak;

  const WeeklyPage({Key? key, required this.settings, required this.tambak})
      : super(key: key);

  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {
  bool _isLoading = true;
  List<ChartData> _data = [];

  _fetch() async {
    final weeklyData = await widget.tambak
        .getBetween(widget.settings.toDate, widget.settings.columnName);

    setState(() {
      _isLoading = false;
      _data = weeklyData
          .map((data) => ChartData(data.waktu, data.weeklyData.value))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[700],
        title:
            Text("Pemantauan ${widget.settings.columnName} 7 Hari Terakhir "),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    title: AxisTitle(text: "Tanggal"),
                    labelIntersectAction: AxisLabelIntersectAction.rotate45,
                    dateFormat: DateFormat("MMM dd"),
                    // maximumLabels: 1,
                    visibleMinimum: _data[0].time,
                    visibleMaximum: _data[6].time,
                    // labelPosition: ChartDataLabelPosition.inside,
                  ),
                  primaryYAxis: NumericAxis(
                      title: AxisTitle(text: widget.settings.columnName)),
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true,
                    enablePinching: true,
                  ),
                  onTooltipRender: (tooltip) {
                    ChartData data = _data[tooltip.pointIndex as int];
                    tooltip.text = DateFormat("HH:mm").format(data.time) +
                        " : ${data.value}";
                  },
                  // Chart title
                  // Enable legend
                  // legend: Legend(isVisible: true),

                  // Enable tooltip
                  // tooltipBehavior: _tooltipBehavior,
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    shouldAlwaysShow: false,
                    format: 'point.x : point.y',
                  ),
                  series: [
                    LineSeries<ChartData, DateTime>(
                      dataSource: _data,
                      name: widget.settings.columnName,
                      xValueMapper: (ChartData sales, _) => sales.time,
                      yValueMapper: (ChartData sales, _) => sales.value,
                      markerSettings: const MarkerSettings(isVisible: true),
                      // Enable data label
                      // dataLabelSettings: DataLabelSettings(isVisible: true),
                    )
                  ]),
              // child: SimpleTimeSeriesChart(
              //     SimpleTimeSeriesChart.convertFetched(_data),
              //     yAxisTitle: widget.settings.columnName),
            ),
    );
  }
}
