import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

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
    } catch (e, stackTrace) {
      print('--- ERRO AO DELETAR PONTO ---');
      print('ID: $id');
      print('ERRO: $e');
      print('STACK TRACE: $stackTrace');
      print('-------------------------------');

      throw Exception('Erro ao deletar ponto de coleta: $e');
    }
  }

  Future<void> atualizarPontoColeta(String id, CollectPointModel updatedPoint) async {
    try {
      await _db.collection(_collectionPath).doc(id).update(updatedPoint.toJSON());
    } catch (e, stackTrace) {
      print('--- ERRO AO ATUALIZAR PONTO DE COLETA ---');
      print('ID: $id');
      print('ERRO: $e');
      print('STACK TRACE: $stackTrace');
      print('-------------------------------');

      throw Exception('Erro ao atualizar ponto de coleta: $e');
    }
  }
}
