import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gerenciador_tarefa01/firebase/firebase_options.dart';
import 'package:gerenciador_tarefa01/home/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _locale = 'pt'; // Idioma padrão
  bool _temaEscuro = false; // Tema padrão

  @override
  void initState() {
    super.initState();
    _loadLocale(); // Carregar o language salvo
    _loadTheme(); // Carregar o tema salvo
  }

  // Método para carregar o language selecionado
  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString('last_locale');
    if (savedLocale != null) {
      setState(() {
        _locale = savedLocale;
      });
    }
  }

  // Método para carregar o tema selecionado
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _temaEscuro = prefs.getBool('tema_escuro') ?? false;
    });
  }

  // Método para salvar o estado do tema
  Future<void> _saveTheme(bool darkTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro', darkTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      theme: _temaEscuro ? ThemeData.dark() : ThemeData.light(),
      locale: Locale(_locale), // Definir o language da aplicação
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
      home: const BemVindoPage(), // Página inicial
    );
  }
}
