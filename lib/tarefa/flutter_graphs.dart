import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskPieChart extends StatelessWidget {
  final int completedTasks;
  final int ongoingTasks;
  final int overdueTasks;

  TaskPieChart({
    required this.completedTasks,
    required this.ongoingTasks,
    required this.overdueTasks, required Null Function(dynamic segmentIndex) onSegmentTapped,
  });

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> showingSections = [
      PieChartSectionData(
        value: completedTasks > 0 ? completedTasks.toDouble() : 0.1,
        color: Colors.green,
        title: 'Concluídas\n$completedTasks',
      ),
      PieChartSectionData(
        value: ongoingTasks > 0 ? ongoingTasks.toDouble() : 0.1,
        color: Colors.yellow,
        title: 'Em Andamento\n$ongoingTasks',
      ),
      PieChartSectionData(
        value: overdueTasks > 0 ? overdueTasks.toDouble() : 0.1,
        color: Colors.red,
        title: 'Atrasadas\n$overdueTasks',
      ),
    ];

    return Container(
      height: 400, // Altura ajustada para um gráfico maior
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: showingSections,
          borderData: FlBorderData(show: false),
          startDegreeOffset: 180,
        ),
      ),
    );
  }
}
