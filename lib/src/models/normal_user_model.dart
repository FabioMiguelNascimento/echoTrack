import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/base/user_base_model.dart';

class NormalUserModel extends UsuarioBaseModel {
  final String? cpf; // Ex: Cliente tem CPF, os outros não

  NormalUserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.country,
    required super.state,
    required super.city,
    required this.cpf,
  }) : super(role: 'user'); // Trava a 'role' para 'cliente'

  factory NormalUserModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NormalUserModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      country: data['country'] ?? '',
      state: data['state'] ?? '',
      city: data['city'],
      cpf: data['cpf'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({'cpf': cpf});
    return data;
  }
}
