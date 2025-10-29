import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/base/user_base_model.dart';

class AdminModel extends UsuarioBaseModel {
  final String city; // <-- Campo específico do Admin

  AdminModel({
    required super.uid,
    required super.email,
    required super.password,
    required super.name,
    required this.city,
  }) : super(role: 'admin'); // Trava a 'role' para 'admin'

  // Construtor que lê o JSON
  factory AdminModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      name: data['nome'] ?? '',
      city: data['municipio'] ?? '', // <-- Pega o campo específico
    );
  }

  // Sobrescreve o toJson() para adicionar o campo específico
  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson(); // Pega os campos comuns (uid, email, nome, role)
    data.addAll({
      'city': city, // Adiciona o campo específico
    });
    return data;
  }
}