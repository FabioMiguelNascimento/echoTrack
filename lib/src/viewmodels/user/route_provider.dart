import 'package:flutter/foundation.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

class RouteProvider extends ChangeNotifier {
  CollectPointModel? _destination;

  CollectPointModel? get destination => _destination;

  /// Define o ponto para onde o usuário quer traçar rota
  void setDestination(CollectPointModel point) {
    _destination = point;
    notifyListeners();
  }

  /// Limpa a rota
  void clearDestination() {
    _destination = null;
    notifyListeners();
  }
}
