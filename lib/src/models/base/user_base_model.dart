import 'package:cloud_firestore/cloud_firestore.dart';

// Importe os modelos filhos que você criará abaixo
import 'package:g1_g2/src/models/admin_model.dart';
import 'package:g1_g2/src/models/normal_user_model.dart';
import 'package:g1_g2/src/models/store_model.dart';

abstract class UsuarioBaseModel {
  final String uid;
  final String email;
  final String password;
  final String name;
  final String role; // 'admin', 'cliente', 'loja'

  UsuarioBaseModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  // *** A MÁGICA ACONTECE AQUI ***
  // Este é um "construtor-fábrica". Ele lê o JSON do Firestore,
  // olha o campo 'role' e decide qual classe filha instanciar.
  factory UsuarioBaseModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String role =
        data['role'] ?? 'cliente'; // Padrão para cliente se não houver

    switch (role) {
      case 'admin':
        return AdminModel.fromJson(doc);
      case 'loja':
        return StoreModel.fromJson(doc);
      case 'cliente':
      default:
        return NormalUserModel.fromJson(doc);
    }
  }

  // Método comum para salvar dados (pode ser sobrescrito)
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'password': password, 'nome': name, 'role': role};
  }
}
