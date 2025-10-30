import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método para "ligar" o loading
  void setLoading(bool value) {
    _isLoading = value;
    // Limpa erros antigos ao iniciar o loading
    if (value) _errorMessage = null; 
    notifyListeners();
  }

  // Método para definir uma mensagem de erro
  void setError(String? message) {
    _errorMessage = message;
    _isLoading = false; // Garante que o loading pare se der erro
    notifyListeners();
  }
}