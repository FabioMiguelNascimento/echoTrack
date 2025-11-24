import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/discart_model.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/repositories/discart_repository.dart';
import 'package:g1_g2/src/repositories/user_repository.dart';
import 'package:g1_g2/src/repositories/coupon_repository.dart';
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';

class DiscartViewmodel extends BaseViewModel {
  final DiscartRepository _discartRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final CouponRepository _couponRepository;

  DiscartViewmodel(this._discartRepository, this._authRepository, this._userRepository, this._couponRepository);

  /* ----------------- FORMULÁRIO PARA REGISTRO DE DESCARTE ----------------- */

  // Controllers para o formulário
  // Form controllers
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController observationController = TextEditingController();

  // Método para registrar o descarte
  // Register discart method
  Future<bool> registerDiscart() async {
    setLoading(true);
    notifyListeners();
    try {
      // Basic validation
      if (selectedTrashType.isEmpty || quantityController.text.isEmpty) {
        throw Exception('Selecione o tipo de lixo e a quantidade aproximada.');
      }

      // get logged user
      final user = _authRepository.currentUser;
      if (user == null) {
        throw Exception('Usuário não logado');
      }

      // create the model
      final newDiscart = DiscartModel(
        uid: null,
        ownerUid: user.uid,
        status: 'pendente',
        trashType: selectedTrashType.trim(),
        aproxQuantity: quantityController.text.trim(),
        observations: observationController.text.trim(),
      );

      // send to repository
      await _discartRepository.createDiscart(newDiscart);

      clearForm();

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  // Seleção do tipo de lixo
  // Selection of trash type
  String selectedTrashType = '';

  final List<String> availableTrashTypes = [
    'Plástico',
    'Papel',
    'Vidro',
    'Metal',
    'Orgânico',
    'Eletrônico',
    'Tecido',
  ];

  // Método para selecionar um tipo de lixo
  // Method for select a trash type
  void selectTrashType(String type) {
    if (selectedTrashType == type) {
      selectedTrashType = type;
    } else {
      selectedTrashType = type;
    }
    notifyListeners();
  }

  void clearForm() {
    selectedTrashType = '';
    quantityController.clear();
    observationController.clear();
  }

  /* ------------------------------------------------------------------------ */

  /* ---------- HISTÓRICO DE DESCARTES DO USUÁRIO --------------------------- */

  // Lista de descartes
  // Discarts list
  List<DiscartModel> _userDiscarts = [];
  List<DiscartModel> get userDiscarts => List.unmodifiable(_userDiscarts);

  // Carregar os descartes do usuário
  // load user discarts
  Future<void> loadUserHistory() async {
    setLoading(true);
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        throw Exception('Usuário não logado.');
      }

      final list = await _discartRepository.getDiscartsByUser(user.uid);

      // Ordena a lista: se for 'pendente' vem antes (-1), se não, vai depois (1)
      list.sort((a, b) {
        final statusA = a.status.toLowerCase();
        final statusB = b.status.toLowerCase();

        if (statusA == 'pendente' && statusB != 'pendente') {
          return -1; // 'a' vem primeiro
        } else if (statusA != 'pendente' && statusB == 'pendente') {
          return 1; // 'b' vem primeiro
        } else {
          return 0; // Mantém a ordem original entre eles
        }
      });

      _userDiscarts = list;

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Ação: Marcar como concluído
  // Action: Set as finished
  Future<void> completeDiscart(String uid) async {
    await _updateDiscartStatus(uid, 'concluido');
  }

  // Ação: Marcar como cancelado
  // Action: Set as canceled
  Future<void> cancelDiscart(String uid) async {
    await _updateDiscartStatus(uid, 'cancelado');
  }

  Future<void> _updateDiscartStatus(String uid, String status) async {
    setLoading(true);
    try {
      await _discartRepository.updateStatus(uid, status);

      if (status == 'concluido') {
        final user = _authRepository.currentUser;
        if (user != null) {
          // incrementa e obtém o novo total
          final newCount = await _userRepository.incrementCollections(user.uid, 1);
          // chama o repositório de cupons para conceder cupons elegíveis
          await _couponRepository.grantEligibleCouponsForUser(userId: user.uid, userCollectionsCount: newCount);
        }
      }

      await loadUserHistory(); // Recarrega a lista para exibir a mudança
      notifyListeners();
    } catch (e) {
      setError('Erro ao atualizar o status: $e');
    } finally {
      setLoading(false);
    }
  }

  /* ------------------------------------------------------------------------ */
}
