import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/discart_model.dart';

class DiscartRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'discarts';

  // Salvar um novo registro de descarte no firestore
  // To save a new discart registration in the firestore
  Future<void> createDiscart(DiscartModel model) async {
    try {
      await _db.collection(_collectionPath).add(model.toJson());
    } catch (e) {
      throw Exception('Erro ao registrar descarte: $e');
    }
  }

  // Busca os descartes de um usuário especifico
  // To search the specify user discarts
  Future<List<DiscartModel>> getDiscartsByUser(String ownerUid) async {
    try {
      final snapshot = await _db
          .collection(_collectionPath)
          .where('ownerUid', isEqualTo: ownerUid)
          .get();
      return snapshot.docs.map((doc) {
        return DiscartModel.fromJson(doc.data(), uid: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar descartes: $e');
    }
  }

  // Atualiza o status do descarte pelo id
  // Update the discart status by id
  Future<void> updateStatus(String uid, String newStatus) async {
    try {
      await _db.collection(_collectionPath).doc(uid).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }
}
