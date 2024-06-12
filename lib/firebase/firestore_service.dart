import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nome;
  final String email;
  final String imageUrl;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.imageUrl,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

class Funcionario {
  final String id;
  final String nome;
  final String cargo;
  final bool emFerias;

  Funcionario({
    required this.id,
    required this.nome,
    required this.cargo,
    this.emFerias = false,
  });

  factory Funcionario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Funcionario(
      id: doc.id,
      nome: data['nome'] ?? '',
      cargo: data['cargo'] ?? '',
      emFerias: data['emFerias'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cargo': cargo,
      'emFerias': emFerias,
    };
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Usuario>> getUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('usuarios').get();
      return querySnapshot.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao recuperar usuários: $e');
      return [];
    }
  }

  Future<List<String>> getUsersNames() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('usuarios').get();
      return querySnapshot.docs.map((doc) => doc['nome'] as String).toList();
    } catch (e) {
      print('Erro ao recuperar nomes de usuários: $e');
      return [];
    }
  }

  Future<void> addFuncionario(Funcionario funcionario) async {
    try {
      await _firestore.collection('funcionarios').add(funcionario.toJson());
    } catch (e) {
      print('Erro ao salvar funcionário: $e');
    }
  }

  Future<void> deleteFuncionario(String id) async {
    try {
      await _firestore.collection('funcionarios').doc(id).delete();
    } catch (e) {
      print('Erro ao excluir funcionário: $e');
    }
  }

  Future<void> updateFuncionario(Funcionario funcionario) async {
    try {
      await _firestore.collection('funcionarios').doc(funcionario.id).update(funcionario.toJson());
    } catch (e) {
      print('Erro ao atualizar funcionário: $e');
    }
  }

  Future<List<Funcionario>> getFuncionarios() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('funcionarios').get();
      return querySnapshot.docs.map((doc) => Funcionario.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao recuperar funcionários: $e');
      return [];
    }
  }

  Future<List<Funcionario>> getFuncionariosPorCargo(String cargo) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('funcionarios').where('cargo', isEqualTo: cargo).get();
      return querySnapshot.docs.map((doc) => Funcionario.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao recuperar funcionários por cargo: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSorteiosSalvos() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('sorteios').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'data': data['data'],
          'resultado': Map<String, String>.from(data['resultado'] ?? {}),
        };
      }).toList();
    } catch (e) {
      print('Erro ao recuperar sorteios salvos: $e');
      return [];
    }
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    await _firestore.collection('tasks').add(taskData);
  }

  Future<void> sendNotification(Map<String, dynamic> notificationData) async {
    await _firestore.collection('notificacoes').add(notificationData);
  }

  Future<void> salvarSorteio(String colecao, Map<String, String> resultado) async {
    try {
      String dataSorteio = DateTime.now().toString();
      await _firestore.collection(colecao).doc(dataSorteio).set({
        'data': dataSorteio,
        'resultado': resultado,
      });
    } catch (e) {
      throw Exception('Erro ao salvar resultado do sorteio: $e');
    }
  }
}
