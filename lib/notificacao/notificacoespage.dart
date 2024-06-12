import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Página principal que exibe as notificações
class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context), // Constroi o AppBar
      body: _buildBody(), // Constroi o corpo da página
    );
  }

  // Método para construir o AppBar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Notificações'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // Método para construir o corpo da página
  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notificações',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: NotificationList(), // Mostra a lista de notificações
          ),
        ],
      ),
    );
  }
}

// Widget que exibe a lista de notificações
class NotificationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getNotificationStream(), // Obtém o stream de notificações do Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(); // Exibe um indicador de carregamento
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error); // Exibe uma mensagem de erro
        }

        final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        if (documents.isEmpty) {
          return _buildEmptyState(); // Exibe uma mensagem se não houver notificações
        }

        return _buildNotificationList(documents); // Constroi a lista de notificações
      },
    );
  }

  // Método para obter o stream de notificações do Firestore
  Stream<QuerySnapshot> _getNotificationStream() {
    return FirebaseFirestore.instance.collection('notificacoes').orderBy('timestamp', descending: true).snapshots();
  }

  // Método para construir o indicador de carregamento
  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  // Método para construir a mensagem de erro
  Widget _buildErrorState(Object? error) {
    return Center(child: Text('Erro: $error'));
  }

  // Método para construir a mensagem de estado vazio
  Widget _buildEmptyState() {
    return Center(child: Text('Sem notificações'));
  }

  // Método para construir a lista de notificações
  Widget _buildNotificationList(List<QueryDocumentSnapshot> documents) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final notification = documents[index].data() as Map<String, dynamic>;
        final timestamp = _getTimestamp(notification);
        return _buildNotificationItem(notification, timestamp);
      },
    );
  }

  // Método para obter o timestamp de uma notificação
  DateTime _getTimestamp(Map<String, dynamic> notification) {
    return notification['timestamp'] != null
        ? (notification['timestamp'] as Timestamp).toDate()
        : DateTime.now();
  }

  // Método para construir um item de notificação
  Widget _buildNotificationItem(Map<String, dynamic> notification, DateTime timestamp) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
          title: Text(notification['title']),
          subtitle: _buildNotificationDetails(notification, timestamp),
        ),
      ),
    );
  }

  // Método para construir os detalhes da notificação
  Widget _buildNotificationDetails(Map<String, dynamic> notification, DateTime timestamp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(notification['body']),
        SizedBox(height: 4),
        Text(
          'Data: ${DateFormat('dd/MM/yyyy').format(timestamp)}',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'Hora: ${DateFormat('HH:mm').format(timestamp)}',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NotificacoesPage(),
  ));
}
