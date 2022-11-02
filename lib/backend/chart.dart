import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Chart extends StatelessWidget {
  final List<SensorValue> _data;

  const Chart(this._data, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      [
        charts.Series<SensorValue, DateTime>(
            id: 'Values',
            colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
            domainFn: (SensorValue values, _) => values.time,
            measureFn: (SensorValue values, _) => values.value,
            data: _data)
      ],
      animate: false,
      primaryMeasureAxis: const charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
        renderSpec: charts.NoneRenderSpec(),
      ),
      domainAxis:
          const charts.DateTimeAxisSpec(renderSpec: charts.NoneRenderSpec()),
    );
  }
}

class SensorValue {
  final DateTime time;
  final double value;

  SensorValue(this.time, this.value);
}
