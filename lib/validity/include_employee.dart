import 'package:flutter/material.dart';
import 'package:gerenciador_tarefa01/firebase/firestore_service.dart';
import 'package:gerenciador_tarefa01/validity/include_employee.dart';

class IncluirFuncionarioPage extends StatefulWidget {
  final Funcionario? funcionario;

  IncluirFuncionarioPage({this.funcionario});

  @override
  _IncluirFuncionarioPageState createState() => _IncluirFuncionarioPageState();
}

class _IncluirFuncionarioPageState extends State<IncluirFuncionarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  String? _selectedCargo;
  final List<String> _cargos = ['Atendente', 'Balconista', 'Farmacêutico'];
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.funcionario != null) {
      _nomeController.text = widget.funcionario!.nome;
      _selectedCargo = widget.funcionario!.cargo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.funcionario == null ? 'Incluir Funcionário' : 'Editar Funcionário'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do funcionário';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCargo,
                decoration: InputDecoration(labelText: 'Cargo'),
                items: _cargos.map((cargo) {
                  return DropdownMenuItem(
                    value: cargo,
                    child: Text(cargo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCargo = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o cargo do funcionário';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final funcionario = Funcionario(
                      id: widget.funcionario?.id ?? '',
                      nome: _nomeController.text,
                      cargo: _selectedCargo!,
                    );
                    if (widget.funcionario == null) {
                      _firestoreService.addFuncionario(funcionario);
                    } else {
                      _firestoreService.updateFuncionario(funcionario);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(widget.funcionario == null
                          ? 'Funcionário adicionado com sucesso'
                          : 'Funcionário atualizado com sucesso'),
                    ));
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.funcionario == null ? 'Adicionar Funcionário' : 'Atualizar Funcionário'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }
}
