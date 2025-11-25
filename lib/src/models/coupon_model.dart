import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String storeId;
  final String title;
  final String description;
  final String discount; // e.g. '15%', 'R$ 5,00'
  final DateTime? validUntil;
  final int minCollections; // mínimo de coletas para liberar
  final int quantityAvailable;

  CouponModel({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.discount,
    this.validUntil,
    required this.minCollections,
    required this.quantityAvailable,
  });

  factory CouponModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CouponModel(
      id: doc.id,
      storeId: data['storeId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      discount: data['discount'] ?? '',
      validUntil: data['validUntil'] != null ? (data['validUntil'] as Timestamp).toDate() : null,
      minCollections: (data['minCollections'] ?? 0) as int,
      quantityAvailable: (data['quantityAvailable'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'title': title,
      'description': description,
      'discount': discount,
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'minCollections': minCollections,
      'quantityAvailable': quantityAvailable,
    };
  }
}
