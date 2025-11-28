import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:g1_g2/src/models/route_model.dart';
import 'package:g1_g2/src/services/route_service.dart';
import 'package:g1_g2/src/constants/map_constants.dart';

class RouteProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();

  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  LatLng? _currentLocation;
  LatLng? _selectedStartPoint;
  LatLng? _selectedEndPoint;

  RouteModel? _currentRoute;
  bool _isLoadingRoute = false;
  String? _errorMessage;

  // Getters
  GoogleMapController get mapController => _mapController;
  Set<Polyline> get polylines => _polylines;
  Set<Marker> get markers => _markers;
  LatLng? get currentLocation => _currentLocation;
  LatLng? get selectedStartPoint => _selectedStartPoint;
  LatLng? get selectedEndPoint => _selectedEndPoint;
  RouteModel? get currentRoute => _currentRoute;
  bool get isLoadingRoute => _isLoadingRoute;
  String? get errorMessage => _errorMessage;

  /// Inicializa o controlador do mapa
  void initMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  /// Obtém a localização atual
  Future<void> getCurrentLocation() async {
    try {
      _errorMessage = null;
      final location = await _routeService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        _selectedStartPoint = location;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erro ao obter localização: $e';
      notifyListeners();
    }
  }

  /// Define o ponto de origem
  void setStartPoint(LatLng point) {
    _selectedStartPoint = point;
    _updateMarkers();
    notifyListeners();
  }

  /// Define o ponto de destino
  void setEndPoint(LatLng point) {
    _selectedEndPoint = point;
    _updateMarkers();
    notifyListeners();
  }

  /// Obtém a rota entre dois pontos
  Future<void> fetchRoute({
    required LatLng startPoint,
    required LatLng endPoint,
  }) async {
    try {
      _isLoadingRoute = true;
      _errorMessage = null;
      _selectedStartPoint = startPoint;
      _selectedEndPoint = endPoint;
      notifyListeners();

      // Chama a Directions API via RouteService para obter dados completos
      final routeDetails = await _routeService.getRouteDetails(
        startPoint: startPoint,
        endPoint: endPoint,
      );

      final polylinePoints = routeDetails['polyline'] as List<LatLng>;

      if (polylinePoints.isEmpty) {
        _errorMessage = 'Não foi possível encontrar uma rota';
        _isLoadingRoute = false;
        notifyListeners();
        return;
      }

      // Obtém distância e duração reais da API
      final distanceInMeters = routeDetails['distance'] as int;
      final durationInSeconds = routeDetails['duration'] as int;
      final startAddress = routeDetails['startAddress'] as String?;
      final endAddress = routeDetails['endAddress'] as String?;

      // Cria o modelo da rota com dados reais da API
      _currentRoute = RouteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startLocation: startPoint,
        endLocation: endPoint,
        startAddress: startAddress ?? 'Ponto de origem',
        endAddress: endAddress ?? 'Ponto de destino',
        polylinePoints: polylinePoints,
        distanceInMeters: distanceInMeters.toDouble(),
        estimatedDuration: Duration(seconds: durationInSeconds),
        createdAt: DateTime.now(),
      );

      // Atualiza as polilinhas e marcadores
      _updatePolylines(polylinePoints);
      _updateMarkers();

      // Anima a câmera para mostrar a rota completa
      _animateCameraToRoute(polylinePoints);

      _isLoadingRoute = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao obter rota: $e';
      print('Erro ao buscar rota: $e');
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  /// Atualiza os marcadores no mapa
  void _updateMarkers() {
    _markers.clear();

    if (_selectedStartPoint != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _selectedStartPoint!,
          infoWindow: const InfoWindow(title: 'Ponto de Origem'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    if (_selectedEndPoint != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _selectedEndPoint!,
          infoWindow: const InfoWindow(title: 'Ponto de Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  /// Atualiza as polilinhas no mapa
  void _updatePolylines(List<LatLng> polylinePoints) {
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylinePoints,
        color: Color(MapConstants.polylineColor),
        width: MapConstants.polylineWidth,
        geodesic: true,
      ),
    );
  }

  /// Anima a câmera para focar na rota
  void _animateCameraToRoute(List<LatLng> polylinePoints) {
    if (polylinePoints.isEmpty ||
        !_mapController.toString().contains('GoogleMapController')) {
      return;
    }

    final bounds = _calculateBounds(polylinePoints);
    final camera = CameraUpdate.newLatLngBounds(
      bounds,
      MapConstants.routePadding,
    );

    _mapController.animateCamera(camera);
  }

  /// Calcula os limites geográficos de um conjunto de pontos
  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (final point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Limpa a rota atual
  void clearRoute() {
    _currentRoute = null;
    _polylines.clear();
    _selectedStartPoint = null;
    _selectedEndPoint = null;
    _markers.clear();
    _errorMessage = null;
    notifyListeners();
  }

  /// Anima a câmera para um ponto específico
  void animateToLocation(LatLng location) {
    _mapController.animateCamera(CameraUpdate.newLatLng(location));
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
