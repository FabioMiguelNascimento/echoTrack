// Libs
import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

// Repositories
import 'package:g1_g2/src/repositories/collect_point_repository.dart';

// ViewModel Base
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';

class CadastroPontoViewmodel extends BaseViewModel {
  final CollectPointRepository _collectPointRepo;

  CadastroPontoViewmodel(this._collectPointRepo);

  // Lista de tipos de lixo disponíveis (pode ser movida para uma constante ou config)
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
      await _collectPointRepo.adicionarPontoColeta(novoPonto);

      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  // Método para limpar os campos do formulário
  void clear() {
    nameController.clear();
    postalController.clear();
    countryController.clear();
    stateController.clear();
    cityController.clear();
    neighborhoodController.clear();
    streetController.clear();
    numberController.clear();
    selectedTrashTypes.clear();
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
}
