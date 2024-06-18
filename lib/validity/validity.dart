import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador_tarefa01/firebase/firestore_service.dart' as firebase;
import 'package:gerenciador_tarefa01/validity/generator_validity.dart' as validade;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:share/share.dart';

import 'include_employee.dart';

class ValidadePage extends StatefulWidget {
  const ValidadePage({Key? key}) : super(key: key);

  @override
  _ValidadePageState createState() => _ValidadePageState();
}

class _ValidadePageState extends State<ValidadePage> {
  List<firebase.Funcionario> funcionarios = [];
  Map<String, List<String>> sorteio = {};
  Map<String, bool> funcionariosSelecionados = {};

  @override
  void initState() {
    super.initState();
    _carregarFuncionarios();
  }

  Future<void> _carregarFuncionarios() async {
    try {
      funcionarios = await firebase.FirestoreService().getFuncionarios();
      setState(() {
        funcionariosSelecionados = Map.fromIterable(
          funcionarios,
          key: (funcionario) => funcionario.nome,
          value: (funcionario) => true, // Todos os funcionários são pré-selecionados
        );
      });
    } catch (e) {
      print('Erro ao carregar funcionários: $e');
    }
  }

  void _sortearValidade() async {
    if (funcionariosSelecionados.isEmpty || !funcionariosSelecionados.containsValue(true)) {
      _mostrarMensagem('Nenhum funcionário selecionado para sorteio');
      return;
    }

    List<firebase.Funcionario> funcionariosParaSorteio = funcionarios
        .where((funcionario) => funcionariosSelecionados[funcionario.nome]!)
        .toList();

    List<validade.Funcionario> funcionariosParaValidar = funcionariosParaSorteio
        .map((f) => validade.Funcionario(
      id: f.id,
      nome: f.nome,
      cargo: f.cargo,
      emFerias: f.emFerias,
    ))
        .toList();

    validade.GeradorValidade gerador = validade.GeradorValidade(funcionarios: funcionariosParaValidar);
    Map<String, List<String>> resultado = gerador.gerarSorteio();

    DateTime agora = DateTime.now();
    String dataHoraCriacao = DateFormat('dd/MM/yyyy HH:mm').format(agora);
    resultado['dataHoraCriacao'] = [dataHoraCriacao];

    setState(() {
      sorteio = resultado;
    });

    try {
      await firebase.FirestoreService().salvarSorteio('sorteios', _convertResultForSaving(resultado));
      _mostrarMensagem('Sorteio salvo com sucesso!');

      for (var entry in resultado.entries) {
        if (entry.key != 'dataHoraCriacao') {
          for (var setor in entry.value) {
            await _criarNotificacao(
              title: 'Nova tasks criada',
              body: 'Tarefa para ${entry.key} no setor $setor',
              timestamp: agora,
            );
          }
        }
      }
    } catch (e) {
      _mostrarMensagem('Erro ao salvar sorteio: $e');
    }
  }

  Map<String, String> _convertResultForSaving(Map<String, List<String>> result) {
    Map<String, String> convertedResult = {};
    result.forEach((key, value) {
      convertedResult[key] = value.join(', ');
    });
    return convertedResult;
  }

  Future<void> _criarNotificacao({
    required String title,
    required String body,
    required DateTime timestamp,
  }) async {
    await FirebaseFirestore.instance.collection('notificacoes').add({
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
    });
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerador de Validade'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IncluirFuncionarioPage()),
              ).then((_) {
                _carregarFuncionarios();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _compartilharPDF();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sorteio da Validade do Mês',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data do Sorteio: ${_obterDataSorteio()}',
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    // Implementar ação para abrir o calendário ou mostrar mais detalhes sobre a data do sorteio
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildFuncionariosWidget(
                'Atendentes',
                funcionarios
                    .where((funcionario) => funcionario.cargo == 'Atendente')
                    .toList()),
            _buildFuncionariosWidget(
                'Balconistas',
                funcionarios
                    .where((funcionario) => funcionario.cargo == 'Balconista')
                    .toList()),
            _buildFuncionariosWidget(
                'Farmacêuticos',
                funcionarios
                    .where((funcionario) => funcionario.cargo == 'Farmacêutico')
                    .toList()),
            SizedBox(height: 32),
            Text(
              'Resultado do Sorteio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildSorteioResultado(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sortearValidade,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shuffle),
                  SizedBox(width: 8),
                  Text('Sortear e Ver Resultado'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sortearValidade,
        tooltip: 'Sortear Validade',
        child: Icon(Icons.shuffle),
      ),
    );
  }

  Widget _buildFuncionariosWidget(String cargo, List<firebase.Funcionario> funcionarios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          cargo,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _selecionarTodosPorCargo(cargo, true);
                  },
                  child: Text('Selecionar Todos'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _selecionarTodosPorCargo(cargo, false);
                  },
                  child: Text('Deselecionar Todos'),
                ),
              ),
            ),
          ],
        ),
        Column(
          children: funcionarios.map((funcionario) {
            return CheckboxListTile(
              title: Text(funcionario.nome),
              value: funcionariosSelecionados[funcionario.nome] ?? false,
              onChanged: (bool? value) {
                setState(() {
                  funcionariosSelecionados[funcionario.nome] = value ?? false;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _selecionarTodosPorCargo(String cargo, bool selecionar) {
    setState(() {
      funcionariosSelecionados.updateAll((nome, selecionado) {
        var funcionario = funcionarios.firstWhere((f) => f.nome == nome);
        return funcionario.cargo == cargo ? selecionar : selecionado;
      });
    });
  }

  Widget _buildSorteioResultado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data e Hora da Criação: ${sorteio['dataHoraCriacao']?.first ?? ''}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSetorContainer(
                'Atendentes',
                Colors.blue,
                sorteio.keys
                    .where((key) =>
                key != 'dataHoraCriacao' &&
                    funcionarios.any((funcionario) =>
                    funcionario.nome == key &&
                        funcionario.cargo == 'Atendente'))
                    .toList()),
            SizedBox(height: 16),
            _buildSetorContainer(
                'Balconistas',
                Colors.green,
                sorteio.keys
                    .where((key) =>
                key != 'dataHoraCriacao' &&
                    funcionarios.any((funcionario) =>
                    funcionario.nome == key &&
                        funcionario.cargo == 'Balconista'))
                    .toList()),
            SizedBox(height: 16),
            _buildSetorContainer(
                'Farmacêuticos',
                Colors.orange,
                sorteio.keys
                    .where((key) =>
                key != 'dataHoraCriacao' &&
                    funcionarios.any((funcionario) =>
                    funcionario.nome == key &&
                        funcionario.cargo == 'Farmacêutico'))
                    .toList()),
          ],
        ),
      ],
    );
  }

  Widget _buildSetorContainer(String cargo, Color cor, List<String> nomes) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        border: Border.all(color: cor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cargo,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: cor),
          ),
          SizedBox(height: 8),
          if (nomes.isNotEmpty)
            Column(
              children: nomes.map((nome) {
                return ListTile(
                  title: Text(nome),
                  subtitle: Text('Setor: ${sorteio[nome]?.join(', ')}'),
                );
              }).toList(),
            )
          else
            Text(
              'Nenhum funcionário sorteado',
            ),
        ],
      ),
    );
  }

  String _obterDataSorteio() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _compartilharPDF() async {
    final pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pdfLib.EdgeInsets.all(32),
        build: (pdfLib.Context context) {
          return [
            pdfLib.Text(
              'Sorteio de Validade do Mês (Atual)',
              style: pdfLib.TextStyle(
                fontSize: 24,
                fontWeight: pdfLib.FontWeight.bold,
              ),
            ),
            pdfLib.SizedBox(height: 16),
            pdfLib.Text(
              'Data do Sorteio: ${_obterDataSorteio()}',
              style: pdfLib.TextStyle(fontSize: 18),
            ),
            pdfLib.SizedBox(height: 16),
            _buildPDFSetor('Atendentes', 'Atendente', nomesSetor: sorteio.keys
                .where((key) =>
                funcionarios.any((funcionario) =>
                funcionario.nome == key && funcionario.cargo == 'Atendente'))
                .toList()),
            _buildPDFSetor('Balconistas', 'Balconista', nomesSetor: sorteio.keys
                .where((key) =>
                funcionarios.any((funcionario) =>
                funcionario.nome == key && funcionario.cargo == 'Balconista'))
                .toList()),
            _buildPDFSetor(
                'Farmacêuticos', 'Farmacêutico', nomesSetor: sorteio.keys
                .where((key) =>
                funcionarios.any((funcionario) =>
                funcionario.nome == key && funcionario.cargo == 'Farmacêutico'))
                .toList()),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/sorteio_validade.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareFiles(['${output.path}/sorteio_validade.pdf']);
  }

  pdfLib.Widget _buildPDFSetor(String titulo, String cargo,
      {required List<String> nomesSetor}) {
    return pdfLib.Container(
      margin: pdfLib.EdgeInsets.symmetric(vertical: 8.0),
      padding: pdfLib.EdgeInsets.all(12.0),
      decoration: pdfLib.BoxDecoration(
        borderRadius: pdfLib.BorderRadius.circular(8.0),
      ),
      child: pdfLib.Column(
        crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
        children: [
          pdfLib.Text(
            titulo,
            style: pdfLib.TextStyle(
              fontSize: 20,
              fontWeight: pdfLib.FontWeight.bold,
            ),
          ),
          pdfLib.SizedBox(height: 8),
          if (nomesSetor.isNotEmpty)
            pdfLib.Column(
              crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
              children: nomesSetor.map((nome) {
                return pdfLib.Container(
                  margin: pdfLib.EdgeInsets.symmetric(vertical: 4),
                  child: pdfLib.Row(
                    children: [
                      pdfLib.Expanded(
                        child: pdfLib.Text(
                          nome,
                          style: pdfLib.TextStyle(fontSize: 16, fontWeight: pdfLib.FontWeight.bold),
                        ),
                      ),
                      pdfLib.SizedBox(width: 8),
                      pdfLib.Text(
                        'Setor: ${sorteio[nome]?.join(', ') ?? 'N/A'}',
                        style: pdfLib.TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            pdfLib.Text(
              'Nenhum funcionário sorteado',
              style: pdfLib.TextStyle(
                fontStyle: pdfLib.FontStyle.italic,
              ),
            ),
          pdfLib.SizedBox(height: 16), // Espaçamento entre as seções de setores
        ],
      ),
    );
  }

  void _incluirFuncionario() {
    // Implementar ação para adicionar um novo funcionário
  }
}
