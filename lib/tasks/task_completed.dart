import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Página principal que exibe as tarefas concluídas
class TarefasConcluidasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Constrói o AppBar
      body: TaskList(isCompleted: true), // Mostra a lista de tarefas concluídas
    );
  }

  // Método para construir o AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Tarefas Concluídas'),
    );
  }
}

// Widget que exibe a lista de tarefas
class TaskList extends StatelessWidget {
  final bool isCompleted;

  // Construtor que aceita o estado de conclusão das tarefas
  TaskList({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getTaskStream(), // Obtém o stream de tarefas do Firestore
      builder: (context, snapshot) {
        // Exibe um indicador de carregamento enquanto os dados estão sendo carregados
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }
        // Exibe uma mensagem de erro caso ocorra um erro ao carregar os dados
        else if (snapshot.hasError) {
          return _buildErrorState();
        }
        // Exibe uma mensagem caso não haja dados ou a lista esteja vazia
        else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }
        // Constrói a lista de tarefas
        else {
          return _buildTaskList(snapshot.data!.docs);
        }
      },
    );
  }

  // Método para obter o stream de tarefas filtradas pelo estado de conclusão
  Stream<QuerySnapshot> _getTaskStream() {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('isCompleted', isEqualTo: isCompleted)
        .snapshots();
  }

  // Método para construir o indicador de carregamento
  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  // Método para construir a mensagem de erro
  Widget _buildErrorState() {
    return Center(child: Text('Erro ao carregar tarefas'));
  }

  // Método para construir a mensagem de estado vazio
  Widget _buildEmptyState() {
    return Center(child: Text('Nenhuma tasks encontrada'));
  }

  // Método para construir a lista de tarefas
  Widget _buildTaskList(List<QueryDocumentSnapshot> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        var task = tasks[index];
        return _buildTaskItem(task);
      },
    );
  }

  // Método para construir um item de tasks
  Widget _buildTaskItem(QueryDocumentSnapshot task) {
    return Card(
      child: ListTile(
        title: Text(task['title']),
        subtitle: Text(task['description']),
        trailing: _buildTaskCheckbox(task),
      ),
    );
  }

  // Método para construir o checkbox de conclusão da tasks
  Widget _buildTaskCheckbox(QueryDocumentSnapshot task) {
    return Checkbox(
      value: task['isCompleted'],
      onChanged: (bool? value) {
        task.reference.update({'isCompleted': value});
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TarefasConcluidasPage(),
  ));
}
