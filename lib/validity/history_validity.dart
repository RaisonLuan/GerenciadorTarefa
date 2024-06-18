import 'package:flutter/material.dart';
import 'package:gerenciador_tarefa01/firebase/firestore_service.dart';

class ValidadeSalvaPage extends StatefulWidget {
  const ValidadeSalvaPage({Key? key}) : super(key: key);

  @override
  _ValidadeSalvaPageState createState() => _ValidadeSalvaPageState();
}

class _ValidadeSalvaPageState extends State<ValidadeSalvaPage> {
  List<Map<String, dynamic>> sorteios = [];
  int? _expandedIndex; // Índice da lista expandida

  @override
  void initState() {
    super.initState();
    _carregarSorteiosSalvos();
  }

  // Carregar os sorteios salvos do Firestore
  Future<void> _carregarSorteiosSalvos() async {
    try {
      List<Map<String, dynamic>> sorteiosRecuperados = await FirestoreService().getSorteiosSalvos();
      setState(() {
        sorteios = sorteiosRecuperados;
      });
    } catch (e) {
      print('Erro ao carregar sorteios salvos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: sorteios.isNotEmpty ? _buildSorteiosList() : _buildEmptyState(), // Verifica se há sorteios para exibir
    );
  }

  // Construir o AppBar da página
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Sorteios de Validade Salvos',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.blueAccent,
    );
  }

  // Construir a lista de sorteios
  Widget _buildSorteiosList() {
    return ListView.builder(
      itemCount: sorteios.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> sorteio = sorteios[index];
        Map<String, String> resultado = Map<String, String>.from(sorteio['resultado']);
        return _buildSorteioItem(sorteio, resultado, index);
      },
    );
  }

  // Construir um item de sorteio na lista
  Widget _buildSorteioItem(Map<String, dynamic> sorteio, Map<String, String> resultado, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        title: Text(
          'Data: ${sorteio['data']}',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        children: [_buildResultadoList(resultado)], // Exibir os detalhes do sorteio
        onExpansionChanged: (isExpanded) {
          setState(() {
            _expandedIndex = isExpanded ? index : null;
          });
        },
        initiallyExpanded: index == _expandedIndex, // Expandir automaticamente o item quando necessário
      ),
    );
  }

  // Construir a lista de resultados do sorteio
  Widget _buildResultadoList(Map<String, String> resultado) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: resultado.entries.map((entry) {
          return Text(
            '${entry.key}: ${entry.value}',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.black87,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Construir o estado vazio quando não há sorteios
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Nenhum sorteio salvo.',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16.0,
          color: Colors.black,
        ),
      ),
    );
  }
}
