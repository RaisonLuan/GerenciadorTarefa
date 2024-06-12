import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gerenciador_tarefa01/banco/task.dart';

enum OrderBy { name, dueDate, state }

class TaskListWidget extends StatefulWidget {
  final OrderBy orderBy;

  TaskListWidget({required this.orderBy});

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  bool isTaskDelayed(String dueDate) {
    DateTime now = DateTime.now();
    DateTime deadline = _parseDate(dueDate);
    return now.isAfter(deadline);
  }

  DateTime _parseDate(String date) {
    List<String> parts = date.split('/');
    if (parts.length != 3) {
      throw FormatException('Formato de data inválido: $date');
    }
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar tarefas'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nenhuma tarefa encontrada'));
        } else {
          var tasks = snapshot.data!.docs;
          if (widget.orderBy == OrderBy.name) {
            tasks.sort((a, b) => Task.fromFirestore(a)
                .name
                .compareTo(Task.fromFirestore(b).name));
          } else if (widget.orderBy == OrderBy.dueDate) {
            tasks.sort((a, b) => _parseDate(Task.fromFirestore(a).dueDate)
                .compareTo(_parseDate(Task.fromFirestore(b).dueDate)));
          } else if (widget.orderBy == OrderBy.state) {
            tasks.sort((a, b) {
              bool aDelayed = isTaskDelayed(Task.fromFirestore(a).dueDate);
              bool bDelayed = isTaskDelayed(Task.fromFirestore(b).dueDate);
              if (aDelayed && bDelayed) {
                return 0;
              } else if (aDelayed && !bDelayed) {
                return 1;
              } else {
                return -1;
              }
            });
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = Task.fromFirestore(tasks[index]);
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(
                    task.title,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Data Limite: ${task.dueDate}',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  trailing: isTaskDelayed(task.dueDate)
                      ? Icon(Icons.clear, color: Colors.red)
                      : Icon(
                          task.isCompleted ? Icons.check_circle : Icons.pending,
                          color: task.isCompleted ? Colors.green : Colors.grey,
                        ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome da Tarefa: ${task.name}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Descrição: ${task.description}',
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Data: ${task.dueDate}',
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Prioridade: ${task.priority}',
                            textAlign: TextAlign.left,
                          ),
                          if (task.notes != null) ...[
                            SizedBox(height: 8.0),
                            Text(
                              'Notas: ${task.notes}',
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
