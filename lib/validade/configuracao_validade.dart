import 'package:flutter/material.dart';
import 'package:gerenciador_tarefa01/firebase/firestore_service.dart';
import 'package:gerenciador_tarefa01/validade/incluirfuncionario.dart';

class ConfigurarFuncionariosPage extends StatefulWidget {
  @override
  _ConfigurarFuncionariosPageState createState() => _ConfigurarFuncionariosPageState();
}

class _ConfigurarFuncionariosPageState extends State<ConfigurarFuncionariosPage> {
  final _firestoreService = FirestoreService();
  List<Funcionario> _funcionarios = [];
  List<Funcionario> _funcionariosFiltrados = [];
  String _filtroCargo = '';

  @override
  void initState() {
    super.initState();
    _loadFuncionarios();
  }

  Future<void> _loadFuncionarios() async {
    final funcionarios = await _firestoreService.getFuncionarios();
    setState(() {
      _funcionarios = funcionarios;
      _funcionariosFiltrados = funcionarios;
    });
  }

  void _addFuncionario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IncluirFuncionarioPage()),
    ).then((_) => _loadFuncionarios());
  }

  void _editFuncionario(Funcionario funcionario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncluirFuncionarioPage(funcionario: funcionario),
      ),
    ).then((_) => _loadFuncionarios());
  }

  Future<void> _confirmDeleteFuncionario(Funcionario funcionario) async {
    bool confirmado = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza de que deseja excluir o funcionário ${funcionario.nome}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmado != null && confirmado) {
      await _firestoreService.deleteFuncionario(funcionario.nome);
      _loadFuncionarios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Funcionário excluído com sucesso')),
      );
    }
  }

  void _ordenarFuncionariosPorNome() {
    setState(() {
      _funcionariosFiltrados.sort((a, b) => a.nome.compareTo(b.nome));
    });
  }

  void _ordenarFuncionariosPorCargo() {
    setState(() {
      _funcionariosFiltrados.sort((a, b) => a.cargo.compareTo(b.cargo));
    });
  }

  void _filtrarFuncionariosPorCargo(String cargo) {
    setState(() {
      _filtroCargo = cargo;
      _funcionariosFiltrados = _funcionarios.where((funcionario) => funcionario.cargo == cargo).toList();
    });
  }

  void _removerFiltroCargo() {
    setState(() {
      _filtroCargo = '';
      _funcionariosFiltrados = _funcionarios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar Funcionários'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFuncionario,
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'nome') {
                _ordenarFuncionariosPorNome();
              } else if (value == 'cargo') {
                _ordenarFuncionariosPorCargo();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'nome',
                child: Text('Ordenar por Nome'),
              ),
              PopupMenuItem(
                value: 'cargo',
                child: Text('Ordenar por Cargo'),
              ),
            ],
          ),
        ],
      ),
      body: _funcionarios.isEmpty
          ? Center(
        child: Text(
          'Nenhum funcionário cadastrado.',
          style: TextStyle(fontSize: 18.0),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_filtroCargo.isNotEmpty)
            Container(
              color: Colors.blueGrey[100],
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrando por: $_filtroCargo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _removerFiltroCargo,
                    child: Text('Remover Filtro'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _funcionariosFiltrados.length,
              itemBuilder: (context, index) {
                final funcionario = _funcionariosFiltrados[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: ListTile(
                    title: Text(funcionario.nome),
                    subtitle: Text(funcionario.cargo),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesFuncionarioPage(funcionario: funcionario),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editFuncionario(funcionario),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _confirmDeleteFuncionario(funcionario),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetalhesFuncionarioPage extends StatelessWidget {
  final Funcionario funcionario;

  DetalhesFuncionarioPage({required this.funcionario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Funcionário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome: ${funcionario.nome}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Cargo: ${funcionario.cargo}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Detalhes adicionais aqui...',
              style: TextStyle(fontSize: 16.0),
            ),

          ],
        ),
      ),
    );
  }
}