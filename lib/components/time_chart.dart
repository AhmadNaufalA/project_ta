import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;
  final String? yAxisTitle;

  const SimpleTimeSeriesChart(this.seriesList,
      {Key? key, this.animate = false, this.yAxisTitle})
      : super(key: key);

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChart.withSampleData() {
    return SimpleTimeSeriesChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      behaviors: [
        charts.ChartTitle('Tanggal',
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
        if (yAxisTitle != null)
          charts.ChartTitle(yAxisTitle!,
              behaviorPosition: charts.BehaviorPosition.start,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
      ],
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: const charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'dd',
            transitionFormat: 'dd MMM',
          ),
        ),
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeries, DateTime>> _createSampleData() {
    final data = [
      TimeSeries(DateTime(2017, 9, 19), 5),
      TimeSeries(DateTime(2017, 9, 26), 25),
      TimeSeries(DateTime(2017, 10, 3), 100),
      TimeSeries(DateTime(2017, 10, 10), 75),
    ];

    return [
      charts.Series<TimeSeries, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeries sales, _) => sales.time,
        measureFn: (TimeSeries sales, _) => sales.value,
        data: data,
      )
    ];
  }

  //Fungsi untuk convert data yang difetch dari /between ke charts Series
  static List<charts.Series<TimeSeries, DateTime>> convertFetched(
      List<TimeSeries> data) {
    return [
      charts.Series<TimeSeries, DateTime>(
        id: 'chart',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeries sales, _) => sales.time,
        measureFn: (TimeSeries sales, _) => sales.value,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeries {
  final DateTime time;
  final num value;

  TimeSeries(this.time, this.value);
}
