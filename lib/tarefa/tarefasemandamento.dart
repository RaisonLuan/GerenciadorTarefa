import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TarefasEmAndamentoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas em Andamento'),
      ),
      body: TaskList(isCompleted: false), // Mostra as tarefas em andamento
    );
  }
}

class TaskList extends StatelessWidget {
  final bool isCompleted;

  TaskList({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
      //.where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('isCompleted', isEqualTo: isCompleted)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar tarefas'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nenhuma tarefa encontrada'));
        } else {
          var tasks = snapshot.data!.docs;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              return Card(
                child: ListTile(
                  title: Text(task['title']),
                  subtitle: Text(task['description']),
                  trailing: Checkbox(
                    value: task['isCompleted'],
                    onChanged: (bool? value) {
                      task.reference.update({'isCompleted': value});
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
