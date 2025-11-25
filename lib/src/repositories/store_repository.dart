import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/store_model.dart';

class StoreRepository {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'stores';

  Future<void> createStore(StoreModel store) async {
    await _db.collection(_collection).doc(store.uid).set(store.toJson());
  }

  Future<StoreModel?> getStoreById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return StoreModel.fromJson(doc);
  }

  Future<void> updateStore(String id, StoreModel updated) async {
    await _db.collection(_collection).doc(id).update(updated.toJson());
  }
}
