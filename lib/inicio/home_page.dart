import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerenciador_tarefa01/configuracao/configuracoes.dart';
import 'package:gerenciador_tarefa01/firebase/firestore_service.dart';
import 'package:gerenciador_tarefa01/login/checagem_page.dart';
import 'package:gerenciador_tarefa01/notificacao/notificacoespage.dart';
import 'package:gerenciador_tarefa01/tarefa/desempenhotarefa.dart';
import 'package:gerenciador_tarefa01/tarefa/incluirtarefa.dart';
import 'package:gerenciador_tarefa01/tarefa/tarefasatrasada.dart';
import 'package:gerenciador_tarefa01/tarefa/tarefasconcluidas.dart';
import 'package:gerenciador_tarefa01/tarefa/tarefasemandamento.dart';
import 'package:gerenciador_tarefa01/validade/validade.dart';
import 'package:gerenciador_tarefa01/validade/validade_salva.dart';
import 'package:gerenciador_tarefa01/widget/task_list_widget.dart';
import 'package:gerenciador_tarefa01/uploadimagem/uploadimage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../validade/configuracao_validade.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String nome = '';
  String email = '';
  String? imageUrl;
  bool _temaEscuro = false;
  List<Usuario> usuarios = [];
  final FirestoreService _firestoreService = FirestoreService();
  OrderBy _orderBy = OrderBy.name; // Defina um valor padrão para a ordenação

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    pegarUsuario();
    getUsers();
    _carregarEstadoTema();

    // Configurar AnimationController
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Configurar animação de deslizamento
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Configurar animação de rotação
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Iniciar a animação
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Método para obter informações do usuário atual
  void pegarUsuario() async {
    User? usuario = _firebaseAuth.currentUser;
    if (usuario != null) {
      setState(() {
        nome = usuario.displayName ?? '';
        email = usuario.email ?? '';
        imageUrl = usuario.photoURL;
      });
    }
  }

  // Método para obter a lista de usuários do Firestore
  Future<void> getUsers() async {
    List<Usuario> users = await _firestoreService.getUsers();
    setState(() {
      usuarios = users;
    });
  }

  // Método para carregar o estado do tema do SharedPreferences
  Future<void> _carregarEstadoTema() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _temaEscuro = prefs.getBool('tema_escuro') ?? false;
    });
  }

  // Método para salvar o estado do tema no SharedPreferences
  Future<void> _salvarEstadoTema(bool temaEscuro) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro', temaEscuro);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _temaEscuro ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        drawer: _buildDrawer(context),
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  // Método para construir o Drawer
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          Divider(),
          _buildTarefasExpansionTile(),
          _buildValidadeExpansionTile(),
          _buildListTile(Icons.notifications, 'Notificações', () => navigateToPage(NotificacoesPage())),
          _buildListTile(Icons.settings, 'Configurações', () => navigateToPage(ConfiguracoesPage(onLocaleChange: _changeLocale))),
          Divider(),
          _buildListTile(Icons.exit_to_app, 'Sair', sair),
        ],
      ),
    );
  }

  // Método para construir o cabeçalho do Drawer
  DrawerHeader _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple, Colors.deepPurpleAccent],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              UploadImagem(),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    nome,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir um ExpansionTile para Tarefas
  ExpansionTile _buildTarefasExpansionTile() {
    return ExpansionTile(
      leading: Icon(Icons.task),
      title: Text('Tarefas'),
      children: [
        _buildListTile(Icons.add, 'Incluir Tarefa', () => navigateToPage(IncluirTarefaPage())),
        _buildListTile(Icons.pending_actions, 'Tarefas em Andamento', () => navigateToPage(TarefasEmAndamentoPage())),
        _buildListTile(Icons.check_circle, 'Tarefas Concluídas', () => navigateToPage(TarefasConcluidasPage())),
        _buildListTile(Icons.schedule, 'Tarefas Atrasadas', () => navigateToPage(TarefasAtrasadasPage())),
        _buildListTile(Icons.analytics, 'Desempenho de Tarefas', () => navigateToPage(DesempenhoTarefaPage())),
      ],
    );
  }

  // Método para construir um ExpansionTile para Validade
  ExpansionTile _buildValidadeExpansionTile() {
    return ExpansionTile(
      leading: Icon(Icons.calendar_today_outlined),
      title: Text('Validade'),
      children: [
        _buildListTile(Icons.calendar_month_outlined, 'Gerador de Validade', () => navigateToPage(ValidadePage())),
        _buildListTile(Icons.description, 'Validade Salva', () => navigateToPage(ValidadeSalvaPage())),
        _buildListTile(Icons.settings, 'Configurações de Validade', () => navigateToPage(ConfigurarFuncionariosPage())),
      ],
    );
  }

  // Método para construir o AppBar
  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text('Gerenciador de Tarefas'),
      backgroundColor: Colors.deepPurple,
      actions: [
        PopupMenuButton<OrderBy>(
          onSelected: _changeOrder,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<OrderBy>>[
            const PopupMenuItem<OrderBy>(
              value: OrderBy.name,
              child: Text('Ordenar por Nome'),
            ),
            const PopupMenuItem<OrderBy>(
              value: OrderBy.dueDate,
              child: Text('Ordenar por Data'),
            ),
            const PopupMenuItem<OrderBy>(
              value: OrderBy.state,
              child: Text('Ordenar por Estado'),
            ),
          ],
        ),
      ],
    );
  }

  // Método para construir o corpo do Scaffold
  Widget _buildBody() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista de Tarefas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TaskListWidget(orderBy: _orderBy),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir o FloatingActionButton
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => navigateToPage(IncluirTarefaPage()),
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Icon(Icons.add),
      ),
      backgroundColor: Colors.deepPurple,
    );
  }

  // Método para construir um ListTile genérico
  ListTile _buildListTile(IconData icon, String title, Function() onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  // Método para navegar para outra página
  void navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Método para sair do aplicativo
  void sair() async {
    await _firebaseAuth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChecagemPage()),
    );
  }

  // Método para alterar o local
  void _changeLocale(String locale) {
    setState(() {});
  }

  // Método para alterar a ordenação das tarefas
  void _changeOrder(OrderBy value) {
    setState(() {
      _orderBy = value;
    });
  }
}
