import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/base/user_base_model.dart';

class StoreModel extends UsuarioBaseModel {
  final String address; // <-- Campo específico da Loja
  final String cnpj;     // <-- Campo específico da Loja

  StoreModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.country,
    required super.state,
    required super.city,
    required this.address,
    required this.cnpj,
  }) : super(role: 'loja'); // Trava a 'role' para 'loja'

  factory StoreModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      country: data['country'] ?? '',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      address: data['address'] ?? '',
      cnpj: data['cnpj'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'address': address,
      'cnpj': cnpj,
    });
    return data;
  }
}