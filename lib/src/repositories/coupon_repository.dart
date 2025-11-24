import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/coupon_model.dart';
import 'package:g1_g2/src/models/user_coupon_model.dart';

class CouponRepository {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'coupons';
  final String _userCouponCollection = 'user_coupons';

  Future<String> createCoupon(CouponModel coupon) async {
    final ref = await _db.collection(_collection).add(coupon.toJson());
    return ref.id;
  }

  Future<List<CouponModel>> getCouponsByStore(String storeId) async {
    final snap = await _db.collection(_collection).where('storeId', isEqualTo: storeId).get();
    return snap.docs.map((d) => CouponModel.fromDoc(d)).toList();
  }

  Future<CouponModel?> getCouponById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return CouponModel.fromDoc(doc);
  }

  Future<void> assignCouponToUser(UserCouponModel userCoupon) async {
    await _db.collection(_userCouponCollection).add(userCoupon.toJson());
  }

  Future<List<UserCouponModel>> getUserCoupons(String userId) async {
    final snap = await _db.collection(_userCouponCollection).where('userId', isEqualTo: userId).get();
    return snap.docs.map((d) => UserCouponModel.fromDoc(d)).toList();
  }

  Future<void> decrementCouponQuantity(String couponId) async {
    final ref = _db.collection(_collection).doc(couponId);
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) return;
      final current = (snapshot.data() as Map<String, dynamic>)['quantityAvailable'] ?? 0;
      if (current > 0) {
        tx.update(ref, {'quantityAvailable': current - 1});
      }
    });
  }

  Future<void> updateCoupon(CouponModel coupon) async {
    final ref = _db.collection(_collection).doc(coupon.id);
    await ref.update(coupon.toJson());
  }

  Future<void> deleteCoupon(String couponId) async {
    final ref = _db.collection(_collection).doc(couponId);
    await ref.delete();
  }

  /// Concede cupons disponíveis que satisfazem o critério de `minCollections`.
  /// Este método só atribui cupons que ainda tenham `quantityAvailable > 0`.
  Future<void> grantEligibleCouponsForUser({
    required String userId,
    required int userCollectionsCount,
  }) async {
    // 1. Busca todos os cupons que têm minCollections <= userCollectionsCount
    final snap = await _db.collection(_collection).where('minCollections', isLessThanOrEqualTo: userCollectionsCount).get();

    for (final doc in snap.docs) {
      final coupon = CouponModel.fromDoc(doc);

      // Verifica se ainda há quantidade disponível
      final qty = (doc.data()['quantityAvailable'] ?? 0) as int;
      if (qty <= 0) continue;

      // Opcional: checar se usuário já recebeu esse cupom
      final already = await _db
          .collection(_userCouponCollection)
          .where('userId', isEqualTo: userId)
          .where('couponId', isEqualTo: coupon.id)
          .limit(1)
          .get();
      if (already.docs.isNotEmpty) continue;

      // Atribui o cupom ao usuário e decrementa a quantidade
      final userCoupon = UserCouponModel(
        id: '',
        couponId: coupon.id,
        userId: userId,
        assignedAt: DateTime.now(),
      );
      await assignCouponToUser(userCoupon);
      await decrementCouponQuantity(coupon.id);
    }
  }
}
