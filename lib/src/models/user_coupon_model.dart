import 'package:cloud_firestore/cloud_firestore.dart';

class UserCouponModel {
  final String id;
  final String couponId;
  final String userId;
  final DateTime assignedAt;
  final bool used;

  UserCouponModel({
    required this.id,
    required this.couponId,
    required this.userId,
    required this.assignedAt,
    this.used = false,
  });

  factory UserCouponModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserCouponModel(
      id: doc.id,
      couponId: data['couponId'] ?? '',
      userId: data['userId'] ?? '',
      assignedAt: data['assignedAt'] != null ? (data['assignedAt'] as Timestamp).toDate() : DateTime.now(),
      used: (data['used'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'couponId': couponId,
      'userId': userId,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'used': used,
    };
  }
}
