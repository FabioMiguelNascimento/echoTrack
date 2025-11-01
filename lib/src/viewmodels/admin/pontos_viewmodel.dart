import 'package:flutter/material.dart';
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';
import 'package:g1_g2/src/repositories/collect_point_repository.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

class PontosViewmodel extends BaseViewModel {
  final CollectPointRepository _repository;

  PontosViewmodel(this._repository);

  // Lista de tipos de lixo disponíveis (mesma lista usada no cadastro)
  final List<String> availableTrashTypes = [
    'Plástico',
    'Papel',
    'Vidro',
    'Metal',
    'Orgânico',
    'Eletrônico',
    'Tecido',
  ];

  // Lista dos tipos selecionados pelo usuário
  final List<String> selectedTrashTypes = [];

  // Método para alternar seleção de um tipo de lixo
  void toggleTrashType(String type) {
    if (selectedTrashTypes.contains(type)) {
      selectedTrashTypes.remove(type);
    } else {
      selectedTrashTypes.add(type);
    }
    notifyListeners(); // Notifica a UI para atualizar
  }

  // Controllers usados em formulários (sem dependência direta de Widgets)
  final TextEditingController nameController = TextEditingController();

  // Endereco
  final TextEditingController postalController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  // tenta cadastrar novo ponto - retorna true se conseguir
  Future<bool> cadastrar() async {
    setLoading(true);

    try {
      // Validação
      if (nameController.text.isEmpty ||
          postalController.text.isEmpty ||
          countryController.text.isEmpty ||
          cityController.text.isEmpty ||
          neighborhoodController.text.isEmpty ||
          streetController.text.isEmpty ||
          numberController.text.isEmpty ||
          selectedTrashTypes.isEmpty) {
        throw Exception(
          "Preencha todos os campos obrigatórios e selecione pelo menos um tipo de lixo.",
        );
      }

      // Pegando o modelo de dados
      CollectPointModel novoPonto = CollectPointModel(
        name: nameController.text.trim(),
        address: Address(
          street: streetController.text.trim(),
          city: cityController.text.trim(),
          number: numberController.text.trim(),
          postal: postalController.text.trim(),
          country: countryController.text.trim(),
          state: stateController.text.trim(),
        ),
        isActive: true,
        trashTypes: selectedTrashTypes, // Usando a lista selecionada
      );

      // Salvar no repositório
      await _repository.adicionarPontoColeta(novoPonto);

      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  // Método para limpar os campos do formulário e também a lista local
  void clear() {
    // limpa controllers e seleção
    nameController.clear();
    postalController.clear();
    countryController.clear();
    stateController.clear();
    cityController.clear();
    neighborhoodController.clear();
    streetController.clear();
    numberController.clear();
    selectedTrashTypes.clear();

    // limpa lista de pontos também
    _points = [];
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    nameController.clear();
    postalController.clear();
    countryController.clear();
    stateController.clear();
    cityController.clear();
    neighborhoodController.clear();
    streetController.clear();
    numberController.clear();
    selectedTrashTypes.clear();
    super.addListener(listener);
  }

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

  /// Deletando Ponto de coleta
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

  /// Atualiza um ponto de coleta existente.
  /// Retorna true em caso de sucesso, false em caso de erro.
  Future<bool> updateCollectPoint(String id, CollectPointModel updated) async {
    setLoading(true);
    try {
      await _repository.atualizarPontoColeta(id, updated);
      // Recarrega a lista para refletir alterações
      await loadCollectPoints();
      return true;
    } catch (e) {
      setError('Erro ao atualizar ponto: $e');
      return false;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  // (clear já definido acima)
}
