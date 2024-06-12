import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskPieChart extends StatelessWidget {
  final int completedTasks;
  final int ongoingTasks;
  final int overdueTasks;
  final void Function(int) onSegmentTapped; // Correção aqui

  TaskPieChart({
    required this.completedTasks,
    required this.ongoingTasks,
    required this.overdueTasks,
    required this.onSegmentTapped, // Atualização do construtor
  });

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> showingSections = [
      PieChartSectionData(
        value: completedTasks.toDouble(),
        color: Colors.green,
        title: 'Concluídas\n$completedTasks',
      ),
      PieChartSectionData(
        value: ongoingTasks.toDouble(),
        color: Colors.yellow,
        title: 'Em Andamento\n$ongoingTasks',
      ),
      PieChartSectionData(
        value: overdueTasks.toDouble(),
        color: Colors.red,
        title: 'Atrasadas\n$overdueTasks',
      ),
    ];

    return GestureDetector( // Adição de GestureDetector para lidar com toques no gráfico
      onTap: () {
        // Implemente a lógica aqui para lidar com toques no gráfico
        // Você pode chamar a função de callback onSegmentTapped com o índice do segmento tocado
        // Exemplo: onSegmentTapped(index);
      },
      child: Container(
        height: 400,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: showingSections,
            borderData: FlBorderData(show: false),
            startDegreeOffset: 180,
          ),
        ),
      ),
    );
  }
}
