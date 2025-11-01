import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';
import 'package:g1_g2/src/repositories/collect_point_repository.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

class ListaPontosViewmodel extends BaseViewModel {
  final CollectPointRepository _repository;

  ListaPontosViewmodel(this._repository);

  List<CollectPointModel> _points = [];

  List<CollectPointModel> get points => List.unmodifiable(_points);

  /// Carrega todos os pontos de coleta do repositório.
  Future<void> loadCollectPoints() async {
    setLoading(true);
    try {
      final fetched = await _repository.getAllCollectPoints();
      _points = fetched;
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setError('Falha ao carregar pontos: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Força recarregar os dados (convenience)
  Future<void> refresh() async => await loadCollectPoints();

  // Deletando Ponto de coleta
  Future<void> deleteCollectPoint(String id) async {
    setLoading(true);
    try {
      await _repository.deletarPontoColeta(id);
      // Após exclusão, recarrega a lista atualizada
      await loadCollectPoints();
    } catch (e) {
      setError('Erro ao deletar o ponto: $id / Erro: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Limpa a lista localmente
  void clear() {
    _points = [];
    notifyListeners();
  }
}
