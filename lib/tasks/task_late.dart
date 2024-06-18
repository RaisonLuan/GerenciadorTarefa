import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Página para exibir tarefas atrasadas
class TarefasAtrasadasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas Atrasadas'),
      ),
      body: TaskList(isOverdue: true), // Exibe as tarefas atrasadas
    );
  }
}

// Lista de tarefas
class TaskList extends StatelessWidget {
  final bool isOverdue;

  TaskList({required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Exibe indicador de carregamento
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar tarefas')); // Exibe mensagem de erro
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nenhuma tasks encontrada')); // Exibe mensagem de nenhuma tasks encontrada
        } else {
          var tasks = snapshot.data!.docs;
          var overdueTasks = tasks.where((task) {
            var dueDate;
            try {
              dueDate = DateTime.parse(task['dueDate'].toString().split('/').reversed.join('-')); // Converte a data para o formato adequado
            } catch (e) {
              dueDate = DateTime.parse(task['dueDate']);
            }
            return dueDate.isBefore(DateTime.now()); // Verifica se a data de vencimento é anterior à data atual
          }).toList();

          if (overdueTasks.isEmpty) {
            return Center(child: Text('Nenhuma tasks atrasada encontrada')); // Exibe mensagem de nenhuma tasks atrasada encontrada
          }

          // Exibe a lista de tarefas atrasadas
          return ListView.builder(
            itemCount: overdueTasks.length,
            itemBuilder: (context, index) {
              var task = overdueTasks[index];
              return Card(
                child: ListTile(
                  title: Text(task['title']), // Título da tasks
                  subtitle: Text(task['description']), // Descrição da tasks
                  trailing: Checkbox(
                    value: task['isCompleted'], // Estado da conclusão da tasks
                    onChanged: (bool? value) {
                      // Atualiza o estado de conclusão da tasks no banco de dados
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

void main() {
  runApp(MaterialApp(
    home: TarefasAtrasadasPage(), // Inicializa a aplicação com a página de tarefas atrasadas
  ));
}
