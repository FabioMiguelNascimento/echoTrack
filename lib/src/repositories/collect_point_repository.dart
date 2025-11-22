import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';
import 'package:g1_g2/src/models/feedback_model.dart';

class CollectPointRepository {
  final _db = FirebaseFirestore.instance;
  final String _collectionPath = 'pontosDeColeta';

  Future<void> adicionarPontoColeta(CollectPointModel novoPonto) async {
    try {
      await _db.collection(_collectionPath).add(novoPonto.toJSON());
    } catch (e) {
      throw Exception('Erro ao salvar ponto de coleta: $e');
    }
  }

  Future<List<CollectPointModel>> getAllCollectPoints() async {
    try {
      final querySnapshot = await _db.collection(_collectionPath).get();
      final points = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final model = CollectPointModel.fromJSON(data, id: doc.id);
        return model;
      }).toList();
      return points;
    } catch (e, stackTrace) {
      print('--- ERRO AO BUSCAR PONTOS ---');
      print('ERRO: $e');
      print('STACK TRACE: $stackTrace');
      print('-------------------------------');
      throw Exception('Erro ao buscar pontos de coleta');
    }
  }

  Future<void> deletarPontoColeta(String id) async {
    try {
      return await _db.collection(_collectionPath).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar ponto de coleta: $e');
    }
  }

  Future<void> atualizarPontoColeta(
    String id,
    CollectPointModel updatedPoint,
  ) async {
    try {
      await _db
          .collection(_collectionPath)
          .doc(id)
          .update(updatedPoint.toJSON());
    } catch (e) {
      throw Exception('Erro ao atualizar ponto de coleta: $e');
    }
  }

  /// COMENTÁRIOS DE PONTOS DE COLETA

  // Adicionar comentário em um ponto de coleta específico
  Future<void> addFeedback(String pointId, FeedbackModel feedback) async {
    try {
      await _db
          .collection(_collectionPath)
          .doc(pointId)
          .collection('feedbacks')
          .add(feedback.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar comentário no banco: $e');
    }
  }

  // Buscar feedbacks de um ponto de coleta específico
  Future<List<FeedbackModel>> getFeedbacks(String pointId) async {
    try {
      final snapshot = await _db
          .collection(_collectionPath)
          .doc(pointId)
          .collection('feedbacks')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return FeedbackModel.fromJson(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar comentários do banco: $e');
    }
  }

  // Deletar comentário
  Future<void> delFeedback(
    String userId,
    String pointId,
    String feedbackId,
  ) async {
    // --- VALIDAÇÃO DE SEGURANÇA ---
    if (pointId.isEmpty) throw Exception("ID do Ponto é inválido (vazio)");
    if (feedbackId.isEmpty) throw Exception("ID do Feedback é inválido (vazio)");
    try {
      await _db
          .collection(_collectionPath)
          .doc(pointId)
          .collection('feedbacks')
          .doc(feedbackId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao deletar comentário do banco: $e');
    }
  }
}
