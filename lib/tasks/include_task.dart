import 'package:flutter/material.dart';
import 'package:gerenciador_tarefa01/firebase/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncluirTarefaPage extends StatefulWidget {
  const IncluirTarefaPage({Key? key}) : super(key: key);

  @override
  _IncluirTarefaPageState createState() => _IncluirTarefaPageState();
}

class _IncluirTarefaPageState extends State<IncluirTarefaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _priorityValue = 'Alta';
  String? _selectedUser;
  final FirestoreService _firestoreService = FirestoreService();
  List<Usuario> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    List<Usuario> usuarios = await _firestoreService.getUsers();
    setState(() {
      _usuarios = usuarios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Tarefa'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nome da Tarefa'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um nome para a tasks';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um título';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _dueDateController,
                  decoration: InputDecoration(
                    labelText: 'Data de Vencimento',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (pickedDate != null) {
                      _dueDateController.text =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma data de vencimento';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priorityValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      _priorityValue = newValue!;
                    });
                  },
                  items: <String>['Alta', 'Média', 'Baixa']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Prioridade'),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUser,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUser = newValue;
                    });
                  },
                  items: _usuarios
                      .map<DropdownMenuItem<String>>((Usuario usuario) {
                    return DropdownMenuItem<String>(
                      value: usuario.id,
                      child: Text(usuario.nome),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Atribuir para'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Notas'),
                  maxLines: 3,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      adicionarTarefa();
                    }
                  },
                  child: Text('Adicionar Tarefa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void adicionarTarefa() async {
    String name = _nameController.text;
    String title = _titleController.text;
    String description = _descriptionController.text;
    String dueDate = _dueDateController.text;
    String notes = _notesController.text;

    showProgressIndicator();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        if (_selectedUser != null) {
          // Atribuir tasks a um usuário específico
          await _firestoreService.addTask({
            'name': name,
            'title': title,
            'description': description,
            'dueDate': dueDate,
            'priority': _priorityValue,
            'notes': notes,
            'isCompleted': false,
            'userId': _selectedUser,
            'createdAt': FieldValue.serverTimestamp(),
          });
          await _firestoreService.sendNotification({
            'title': 'Nova Tarefa Adicionada',
            'body': 'A tasks "$title" foi adicionada.',
            'userId': _selectedUser,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Disparar tasks para todos os usuários
          for (Usuario usuario in _usuarios) {
            await _firestoreService.addTask({
              'name': name,
              'title': title,
              'description': description,
              'dueDate': dueDate,
              'priority': _priorityValue,
              'notes': notes,
              'isCompleted': false,
              'userId': usuario.id,
              'createdAt': FieldValue.serverTimestamp(),
            });

            await _firestoreService.sendNotification({
              'title': 'Nova Tarefa Adicionada',
              'body': 'A tasks "$title" foi adicionada.',
              'userId': usuario.id,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }

        _clearFields();
        hideProgressIndicator();
        showSuccessMessage('Tarefa e notificação adicionadas com sucesso!');

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } catch (e) {
        hideProgressIndicator();
        showErrorMessage('Erro ao adicionar a tasks: $e');
      }
    } else {
      hideProgressIndicator();
      showErrorMessage('Nenhum usuário autenticado');
    }
  }

  void showProgressIndicator() {
// Implementar a exibição de um indicador de progresso
  }

  void hideProgressIndicator() {
// Implementar a ocultação do indicador de progresso
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _titleController.clear();
    _descriptionController.clear();
    _dueDateController.clear();
    _notesController.clear();
    setState(() {
      _selectedUser = null;
    });
  }
}
