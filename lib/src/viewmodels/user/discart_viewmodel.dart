import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/discart_model.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/repositories/discart_repository.dart';
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';

class DiscartViewmodel extends BaseViewModel {
  final DiscartRepository _discartRepository;
  final AuthRepository _authRepository;

  DiscartViewmodel(this._discartRepository, this._authRepository);

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
}
