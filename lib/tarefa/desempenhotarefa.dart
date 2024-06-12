import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'flutter_graphs.dart';

void main() {
  runApp(MaterialApp(
    home: DesempenhoTarefaPage(),
  ));
}

// Página para exibir o desempenho das tarefas
class DesempenhoTarefaPage extends StatefulWidget {
  @override
  _DesempenhoTarefaPageState createState() => _DesempenhoTarefaPageState();
}

class _DesempenhoTarefaPageState extends State<DesempenhoTarefaPage> {
  int completedTasks = 0;
  int ongoingTasks = 0;
  int overdueTasks = 0;
  bool isLoading = true;
  List<Task> tasks = []; // Lista de tarefas

  @override
  void initState() {
    super.initState();
    _calculateTaskPerformance();
  }

  Future<void> _calculateTaskPerformance() async {
    try {
      // Filtrar as tarefas pelo usuário logado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Nenhum usuário logado");
      }

      QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .get();

      int completed = 0;
      int ongoing = 0;
      int overdue = 0;
      DateTime now = DateTime.now();
      DateFormat dateFormat = DateFormat('dd/MM/yyyy');

      print('Total tasks retrieved: ${taskSnapshot.docs.length}');

      List<Task> loadedTasks = []; // Lista temporária de tarefas

      for (var task in taskSnapshot.docs) {
        print('Task data: ${task.data()}');

        Task taskObject = Task.fromSnapshot(task); // Criar objeto Task a partir do DocumentSnapshot
        loadedTasks.add(taskObject); // Adicionar à lista temporária

        if (task['isCompleted']) {
          completed++;
        } else {
          DateTime dueDate;
          if (task['dueDate'] is Timestamp) {
            dueDate = (task['dueDate'] as Timestamp).toDate();
          } else if (task['dueDate'] is String) {
            dueDate = dateFormat.parse(task['dueDate']);
          } else {
            continue;
          }

          if (dueDate.isBefore(now)) {
            overdue++;
          } else {
            ongoing++;
          }
        }
      }

      setState(() {
        completedTasks = completed;
        ongoingTasks = ongoing;
        overdueTasks = overdue;
        isLoading = false;
        tasks = loadedTasks; // Atualizar a lista de tarefas com a lista carregada
      });

      print('Tasks loaded:');
      print('Completed: $completedTasks');
      print('Ongoing: $ongoingTasks');
      print('Overdue: $overdueTasks');
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desempenho de Tarefas'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50], // Cor de fundo da caixa
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Desempenho de Tarefas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TaskPieChart(
                      completedTasks: completedTasks,
                      ongoingTasks: ongoingTasks,
                      overdueTasks: overdueTasks,
                      // Adicionar callback para interatividade do gráfico
                      onSegmentTapped: (segmentIndex) {
                        // Implementar lógica para exibir detalhes das tarefas ao tocar nos segmentos do gráfico
                        print('Segment $segmentIndex tapped');
                      },
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        _buildLegendItem(Colors.green, 'Concluídas'),
                        _buildLegendItem(Colors.yellow, 'Em Andamento'),
                        _buildLegendItem(Colors.red, 'Atrasadas'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              tasks.isEmpty
                  ? Center(
                child: Text(
                  'Nenhuma tarefa disponível.',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(tasks[index].title),
                      subtitle: Text(tasks[index].description),
                      trailing: Icon(
                        tasks[index].isCompleted ? Icons.check_circle : Icons.timer,
                        color: tasks[index].isCompleted ? Colors.green : Colors.yellow,
                      ),
                      // Adicionar mais informações conforme necessário
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}

// Classe para representar uma tarefa
class Task {
  final String title;
  final String description;
  final bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  // Construtor para criar uma instância de Task a partir de um DocumentSnapshot
  Task.fromSnapshot(DocumentSnapshot snapshot)
      : title = snapshot['title'],
        description = snapshot['description'],
        isCompleted = snapshot['isCompleted'] ?? false;
}
