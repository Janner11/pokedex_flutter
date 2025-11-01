import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsRadarChart extends StatelessWidget {
  final Map<String, int> stats;
  final Color color;

  // Stats order for the chart
  static const List<String> _statOrder = ['HP', 'ATK', 'DEF', 'SPA', 'SPD', 'SPE'];
  // A more realistic max value to make stat differences more noticeable.
  static const double maxStatValue = 170.0;

  const StatsRadarChart({super.key, required this.stats, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statValues = _statOrder.map((key) => stats[key]?.toDouble() ?? 0.0).toList();

    return AspectRatio(
      aspectRatio: 1.2,
      child: RadarChart(
        RadarChartData(
          titleTextStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),

          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),

          tickBorderData: const BorderSide(color: Colors.black12, width: 1),

          gridBorderData: const BorderSide(color: Colors.black26, width: 1.5),

          getTitle: (index, angle) {
            return RadarChartTitle(
              text: _statOrder[index],
              angle: angle,
            );
          },

          dataSets: [
            // This is the actual data for the pokemon
            RadarDataSet(
              fillColor: color.withOpacity(0.3),
              borderColor: color,
              borderWidth: 2.5,
              entryRadius: 3,
              dataEntries: statValues.map((value) => RadarEntry(value: value)).toList(),
            ),
            // This INVISIBLE data set forces the chart to use a fixed scale (0-170).
            RadarDataSet(
              fillColor: Colors.transparent,
              borderColor: Colors.transparent,
              dataEntries: _statOrder.map((_) => const RadarEntry(value: maxStatValue)).toList(),
            ),
          ],

          radarBackgroundColor: Colors.transparent,
          radarShape: RadarShape.polygon,
          radarBorderData: const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
        ),
      ),
    );
  }
}
