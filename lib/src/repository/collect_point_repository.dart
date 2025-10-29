import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

class CollectPointRepository {
  final _db = FirebaseFirestore.instance;
  final String _collectionPath = 'pontosDeColeta';

  // *** SEU MÉTODO FICA AQUI ***
  Future<void> adicionarPontoColeta(CollectPointModel novoPonto) async {
    try {
      // A lógica de negócio (salvar no Firebase)
      // fica encapsulada aqui.
      await _db.collection(_collectionPath).add(novoPonto.());
    } catch (e) {
      // Tratar erros
      throw Exception('Erro ao salvar ponto de coleta: $e');
    }
  }

  // Você também terá outros métodos aqui:
  // Future<List<PontoColeta>> getTodosPontosColeta() { ... }
  // Future<void> atualizarPontoColeta(PontoColeta ponto) { ... }
  // Future<void> deletarPontoColeta(String id) { ... }
}