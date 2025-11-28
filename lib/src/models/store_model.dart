import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/base/user_base_model.dart';

class StoreModel extends UsuarioBaseModel {
  final String
  address; // <-- Campo específico da Loja (endereço completo para compatibilidade)
  final String cnpj; // <-- Campo específico da Loja
  final String? street; // Rua
  final String? number; // Número
  final String? neighborhood; // Bairro
  final String? imageUrl; // URL da imagem/avatar da loja (Firebase Storage)

  StoreModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.country,
    required super.state,
    required super.city,
    required this.address,
    required this.cnpj,
    this.street,
    this.number,
    this.neighborhood,
    this.imageUrl,
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
      street: data['street'],
      number: data['number'],
      neighborhood: data['neighborhood'],
      imageUrl: data['imageUrl'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'address': address,
      'cnpj': cnpj,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'imageUrl': imageUrl,
    });
    return data;
  }
}
