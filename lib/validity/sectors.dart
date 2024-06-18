import 'package:cloud_firestore/cloud_firestore.dart';

class Setor {
  final String id;
  String nome;

  Setor({required this.id, required this.nome});

  factory Setor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Setor(
      id: doc.id,
      nome: data['nome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
    };
  }
}
