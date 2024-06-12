import 'package:cloud_firestore/cloud_firestore.dart';

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
