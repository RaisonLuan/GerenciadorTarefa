import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ConfiguracoesPage extends StatefulWidget {
  final Function(String) onLocaleChange;

  ConfiguracoesPage({required this.onLocaleChange});

  @override
  _ConfiguracoesPageState createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarNovaSenhaController = TextEditingController();

  bool _temaEscuro = false;
  String _idiomaSelecionado = 'pt';
  bool _notificacoesAtivadas = true;
  bool _expandirTrocaSenha = false;

  @override
  void initState() {
    super.initState();
    preencherInformacoesPerfil();
    _carregarEstadoTema();
    _carregarEstadoIdioma();
  }

  /// Preenche os campos de perfil com as informações do usuário atual do Firebase
  Future<void> preencherInformacoesPerfil() async {
    User? usuario = _firebaseAuth.currentUser;
    if (usuario != null) {
      setState(() {
        _nomeController.text = usuario.displayName ?? '';
        _emailController.text = usuario.email ?? '';
      });
    }
  }

  /// Carrega o estado do tema (claro/escuro) das preferências compartilhadas
  Future<void> _carregarEstadoTema() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _temaEscuro = prefs.getBool('tema_escuro') ?? false;
    });
  }

  /// Carrega o estado do language selecionado das preferências compartilhadas
  Future<void> _carregarEstadoIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idiomaSelecionado = prefs.getString('idioma_selecionado') ?? 'pt';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Intl.message('Configurações')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(Intl.message('Perfil do Usuário')),
            _buildProfileForm(),
            _buildSectionTitle(Intl.message('Preferências do Aplicativo')),
            _buildAppPreferences(),
          ],
        ),
      ),
    );
  }

  /// Cria o título das seções
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Cria o formulário de perfil
  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nomeController,
          decoration: InputDecoration(
            labelText: Intl.message('Nome'),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: Intl.message('E-mail'),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        ListTile(
          title: Text(
            Intl.message('Trocar Senha'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
            _expandirTrocaSenha ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              _expandirTrocaSenha = !_expandirTrocaSenha;
            });
          },
        ),
        if (_expandirTrocaSenha) ...[
          TextFormField(
            controller: _senhaAtualController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: Intl.message('Senha Atual'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _novaSenhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: Intl.message('Nova Senha'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _confirmarNovaSenhaController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: Intl.message('Confirmar Nova Senha'),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
        ],
        ElevatedButton(
          onPressed: () {
            salvarAlteracoesPerfil();
          },
          child: Text(Intl.message('Salvar')),
        ),
      ],
    );
  }

  /// Cria as preferências do aplicativo
  Widget _buildAppPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(Intl.message('Tema Escuro')),
          value: _temaEscuro,
          onChanged: (value) {
            setState(() {
              _temaEscuro = value;
              _salvarEstadoTema(value);
            });
          },
        ),
        DropdownButtonFormField<String>(
          value: _idiomaSelecionado,
          onChanged: (value) {
            setState(() {
              _idiomaSelecionado = value!;
              _salvarEstadoIdioma(value);
              widget.onLocaleChange(value);
            });
          },
          items: <String>['pt', 'en', 'es'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(_getIdiomaLabel(value)),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: Intl.message('Idioma'),
            border: OutlineInputBorder(),
          ),
        ),
        SwitchListTile(
          title: Text(Intl.message('Notificações')),
          value: _notificacoesAtivadas,
          onChanged: (value) {
            setState(() {
              _notificacoesAtivadas = value;
              _salvarEstadoNotificacoes(value);
            });
          },
        ),
      ],
    );
  }

  /// Retorna o label do language
  String _getIdiomaLabel(String value) {
    switch (value) {
      case 'pt':
        return 'Português';
      case 'en':
        return 'Inglês';
      case 'es':
        return 'Espanhol';
      default:
        return 'Português';
    }
  }

  /// Salva as alterações do perfil do usuário
  void salvarAlteracoesPerfil() async {
    User? usuario = _firebaseAuth.currentUser;
    if (usuario != null) {
      String novoNome = _nomeController.text.trim();
      String novaSenha = _novaSenhaController.text.trim();
      String confirmarNovaSenha = _confirmarNovaSenhaController.text.trim();

      if (novoNome.isNotEmpty && novoNome != usuario.displayName) {
        await usuario.updateDisplayName(novoNome);
      }

      if (novaSenha.isNotEmpty && novaSenha == confirmarNovaSenha) {
        try {
          String email = usuario.email!;
          AuthCredential credential = EmailAuthProvider.credential(
            email: email,
            password: _senhaAtualController.text.trim(),
          );

          await usuario.reauthenticateWithCredential(credential);
          await usuario.updatePassword(novaSenha);
        } catch (e) {
          print("Erro ao trocar a senha: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao trocar a senha: $e")),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Perfil atualizado com sucesso")),
      );
    }
  }

  /// Salva o estado do tema nas preferências compartilhadas
  Future<void> _salvarEstadoTema(bool temaEscuro) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('tema_escuro', temaEscuro);
  }

  /// Salva o estado do language nas preferências compartilhadas
  Future<void> _salvarEstadoIdioma(String idioma) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('idioma_selecionado', idioma);
  }

  /// Salva o estado das notificações nas preferências compartilhadas
  Future<void> _salvarEstadoNotificacoes(bool notificacoes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificacoes_ativadas', notificacoes);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  /// Carrega o language selecionado das preferências compartilhadas
  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _locale = prefs.getString('idioma_selecionado') ?? 'pt';
      Intl.defaultLocale = _locale;
    });
  }

  /// Altera o language do aplicativo
  void _changeLocale(String locale) {
    setState(() {
      _locale = locale;
      Intl.defaultLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale(_locale),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ConfiguracoesPage(
        onLocaleChange: _changeLocale,
      ),
    );
  }
}
