import 'package:flutter/material.dart';
import 'package:gerenciador_tarefa01/home/home_page.dart';
import 'package:gerenciador_tarefa01/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BemVindoPage extends StatefulWidget {
  const BemVindoPage({Key? key}) : super(key: key);

  @override
  State<BemVindoPage> createState() => _BemVindoPageState();
}

class _BemVindoPageState extends State<BemVindoPage> {
  @override
  void initState() {
    super.initState();
    verificarUsuario().then((temUsuario) {
      if (temUsuario) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Future<bool> verificarUsuario() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    String? token = _sharedPreferences.getString('token');
    return token != null;
  }
}
