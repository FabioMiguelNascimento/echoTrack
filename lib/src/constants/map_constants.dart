import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapConstants {
  /// Nível de zoom padrão para o mapa
  static const double defaultZoom = 15.0;

  /// Nível de zoom quando focando em uma rota completa
  static const double routeZoom = 12.0;

  /// Nível de zoom máximo
  static const double maxZoom = 21.0;

  /// Nível de zoom mínimo
  static const double minZoom = 2.0;

  /// Localização padrão (São Paulo, Brasil)
  static const LatLng defaultLocation = LatLng(-23.5505, -46.6333);

  /// Cores para polilinhas de rota
  static const int polylineColor = 0xFF1976D2; // Azul

  /// Largura da polilinha
  static const int polylineWidth = 5;

  /// Cor para marcador de origem
  static const int originMarkerColor = 120; // Verde

  /// Cor para marcador de destino
  static const int destinationMarkerColor = 0; // Vermelho

  /// Duração da animação de câmera (em milissegundos)
  static const Duration cameraAnimationDuration = Duration(milliseconds: 500);

  /// Padding padrão ao focar em uma rota
  static const double routePadding = 100.0;

  /// Altura máxima de altitude para visão 3D
  static const double maxTilt = 45.0;

  /// URL base da API do Google Maps
  static const String googleMapsApiUrl = 'https://maps.googleapis.com/maps/api';

  /// Modo de viagem padrão
  static const String defaultTravelMode = 'driving';
}
