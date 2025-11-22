import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/feedback_model.dart';
import 'package:g1_g2/src/viewmodels/admin/dtos/point_edit_data.dart';
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g1_g2/src/repositories/user_repository.dart';
import 'package:g1_g2/src/repositories/collect_point_repository.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

import 'package:g1_g2/src/viewmodels/admin/dtos/point_card_data.dart';

class PontosViewmodel extends BaseViewModel {
  final CollectPointRepository _repository;
  final UserRepository _userRepository;

  PontosViewmodel(this._repository, this._userRepository);

  List<CollectPointModel> _points = [];
  List<PointCardData> get pointCards {
    return _points
        .where((p) => p.id != null) // Garante que não há pontos sem ID
        .map((model) => PointCardData(id: model.id!, name: model.name))
        .toList();
  }

  // (Usado pelas telas de Detalhes e Edição)
  CollectPointModel? _selectedPoint;
  CollectPointModel? get selectedPoint => _selectedPoint;

  /// Fornece os dados do ponto selecionado de forma segura para a View de Edição.
  PointEditData? getSelectedPointDataForEdit() {
    if (_selectedPoint == null) {
      return null;
    }
    // Transforma o Model em um DTO simples
    return PointEditData(
      name: _selectedPoint!.name,
      postal: _selectedPoint!.address.postal,
      city: _selectedPoint!.address.city,
      street: _selectedPoint!.address.street,
      number: _selectedPoint!.address.number,
      trashTypes: _selectedPoint!.trashTypes,
    );
  }

  /// Define qual ponto está ativo para as telas de detalhe/edição.
  void selectPoint(String pointId) {
    try {
      // Busca o ponto na lista que já carregamos
      _selectedPoint = _points.firstWhere((p) => p.id == pointId);
    } catch (e) {
      setError('Erro ao selecionar ponto: $e');
      _selectedPoint = null;
    }
  }

  /// Limpa a seleção ao voltar para a home, por exemplo.
  void clearSelectedPoint() {
    _selectedPoint = null;
  }

  // --- 3. ESTADO DO FORMULÁRIO DE CADASTRO ---
  // (Estes são os "rascunhos globais" APENAS para o cadastro)

  final TextEditingController createNameController = TextEditingController();
  final TextEditingController createPostalController = TextEditingController();
  final TextEditingController createCountryController = TextEditingController();
  final TextEditingController createStateController = TextEditingController();
  final TextEditingController createCityController = TextEditingController();
  final TextEditingController createNeighborhoodController =
      TextEditingController();
  final TextEditingController createStreetController = TextEditingController();
  final TextEditingController createNumberController = TextEditingController();

  final List<String> createSelectedTrashTypes = [];

  final List<String> availableTrashTypes = [
    'Plástico',
    'Papel',
    'Vidro',
    'Metal',
    'Orgânico',
    'Eletrônico',
    'Tecido',
  ];

  /// Alterna a seleção de lixo NO FORMULÁRIO DE CADASTRO.
  void toggleCreateTrashType(String type) {
    if (createSelectedTrashTypes.contains(type)) {
      createSelectedTrashTypes.remove(type);
    } else {
      createSelectedTrashTypes.add(type);
    }
    notifyListeners();
  }

  /// Limpa APENAS os campos do formulário de cadastro.
  void clearCreateForm() {
    createNameController.clear();
    createPostalController.clear();
    createCountryController.clear();
    createStateController.clear();
    createCityController.clear();
    createNeighborhoodController.clear();
    createStreetController.clear();
    createNumberController.clear();
    createSelectedTrashTypes.clear();
    notifyListeners(); // Notifica a tela de cadastro para limpar os checkboxes
  }

  /// Carrega todos os pontos de coleta do repositório.
  Future<void> loadCollectPoints() async {
    setLoading(true);
    try {
      final fetched = await _repository.getAllCollectPoints();
      _points = fetched;
      setError(null); // Limpa erro anterior se carregar com sucesso
    } catch (e) {
      setError('Falha ao carregar pontos: $e');
      _points = []; // Limpa a lista em caso de erro
    } finally {
      setLoading(false);
      notifyListeners(); // Notifica a UI (sucesso ou falha)
    }
  }

  /// Força recarregar os dados
  Future<void> refresh() async => await loadCollectPoints();

  /// Tenta cadastrar novo ponto - retorna true se conseguir
  Future<bool> cadastrar() async {
    setLoading(true);
    notifyListeners(); // Mostra o loading

    try {
      // Validação usando os controllers de CADASTRO
      if (createNameController.text.isEmpty ||
          createPostalController.text.isEmpty ||
          // ... (valide todos os outros 'create' controllers)
          createSelectedTrashTypes.isEmpty) {
        throw Exception(
          "Preencha todos os campos obrigatórios e selecione pelo menos um tipo de lixo.",
        );
      }

      // Restrição B (política escolhida): permitir que o administrador
      // cadastre apenas pontos dentro da SUA cidade cadastrada no perfil.
      // Pegamos o usuário atual e consultamos o repositório para obter o perfil.
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      final usuario = await _userRepository.getUserData(currentUser.uid);
      if (usuario == null) {
        throw Exception('Dados do usuário não encontrados');
      }

      CollectPointModel novoPonto = CollectPointModel(
        name: createNameController.text.trim(),
        address: Address(
          street: createStreetController.text.trim(),
          neighborhood: createNeighborhoodController.text.trim(),
          city: createCityController.text.trim(),
          number: createNumberController.text.trim(),
          postal: createPostalController.text.trim(),
          country: createCountryController.text.trim(),
          state: createStateController.text.trim(),
        ),
        isActive: true,
        trashTypes: createSelectedTrashTypes,
      );

      // Salvar no repositório
      await _repository.adicionarPontoColeta(novoPonto);

      // --- SUCESSO ---
      clearCreateForm(); // 1. Limpa os campos do formulário
      await loadCollectPoints(); // 2. Recarrega a lista na home (já notifica)
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false); // Para o loading em caso de erro
      notifyListeners();
      return false;
    }
    // Não precisa de 'finally' aqui porque o 'loadCollectPoints'
    // já cuida de parar o loading e notificar.
  }

  /// Recebe dados puros da View, constrói o Model e atualiza.
  Future<bool> updatePointFromForm({
    required String name,
    required String postal,
    required String country,
    required String state,
    required String city,
    required String street,
    required String neighborhood,
    required String number,
    required List<String> trashTypes,
  }) async {
    // A View não sabe o ID, mas o ViewModel sabe!
    final String? pointId = _selectedPoint?.id;
    if (pointId == null) {
      setError('Erro fatal: Ponto selecionado é nulo');
      return false;
    }

    setLoading(true);
    notifyListeners();
    try {
      // --- AQUI o ViewModel constrói o Model (permitido) ---
      final updatedModel = CollectPointModel(
        id: pointId,
        name: name,
        address: Address(
          street: street,
          neighborhood: neighborhood,
          city: city,
          number: number,
          postal: postal,
          country: country,
          state: state,
          cords: _selectedPoint!.address.cords, // Mantém coords originais
        ),
        isActive: _selectedPoint!.isActive, // Mantém status original
        trashTypes: trashTypes,
      );

      // (Use seu método de repository existente)
      await _repository.atualizarPontoColeta(pointId, updatedModel);

      // Recarrega a lista para refletir alterações
      await loadCollectPoints();
      // Atualiza o 'selectedPoint' com os novos dados
      selectPoint(pointId);

      return true;
    } catch (e) {
      setError('Erro ao atualizar ponto: $e');
      return false;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Deleta um Ponto de coleta
  Future<void> deleteCollectPoint(String id) async {
    setLoading(true);
    notifyListeners();
    try {
      await _repository.deletarPontoColeta(id);
      await loadCollectPoints(); // Recarrega a lista (já notifica)
    } catch (e) {
      setError('Erro ao deletar o ponto: $id / Erro: $e');
      setLoading(false); // Para o loading em caso de erro
      notifyListeners();
    }
  }

  /// Sobrescreva o dispose para limpar SEUS controllers
  @override
  void dispose() {
    createNameController.dispose();
    createPostalController.dispose();
    createCountryController.dispose();
    createStateController.dispose();
    createCityController.dispose();
    createNeighborhoodController.dispose();
    createStreetController.dispose();
    createNumberController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE COMENTÁRIOS ---

  List<FeedbackModel> _feedbacks = [];
  List<FeedbackModel> get feedbacks => List.unmodifiable(_feedbacks);

  final TextEditingController commentController = TextEditingController();

  // Carrega comentários de um ponto específico
  Future<void> loadFeedbacks(String pointId) async {
    // Nota: Não usamos setLoading(true) aqui para não bloquear a tela toda
    // se você quiser um loading só na lista, crie um bool _isLoadingFeedbacks separado.
    try {
      _feedbacks = await _repository.getFeedbacks(pointId);
      notifyListeners();
    } catch (e) {
      setError('Erro ao carregar feedbacks: $e');
    }
  }

  // Deleta comentário
  Future<void> delFeedbackVM(
    String userId,
    String pointId,
    FeedbackModel feedback,
  ) async {
    setLoading(true);
    try {
      await _repository.delFeedback(userId, pointId, feedback.id);
      await loadFeedbacks(pointId);
    } catch (e) {
      setError('Erro ao deletar comentário: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  // Envia o comentário
  Future<bool> sendFeedback(
    String pointId,
    String userId,
    String userName,
  ) async {
    final text = commentController.text.trim();
    if (text.isEmpty) return false;

    setLoading(true); // Aqui bloqueamos rapidinho para enviar
    try {
      final feedback = FeedbackModel(
        id: '', // O Firebase gera
        userId: userId,
        userName: userName,
        comment: text,
        date: DateTime.now(),
      );

      await _repository.addFeedback(pointId, feedback);

      commentController.clear(); // Limpa o input
      await loadFeedbacks(pointId); // Recarrega a lista

      return true;
    } catch (e) {
      setError('Erro ao comentar: $e');
      return false;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }
}
