import 'dart:math' as math;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class RouteService {
  static const String _googleMapsApiKey =
      'AIzaSyAXjYfYLrCVBAXIVHBkYZgm2EzddLczN-8';

  final Location _location = Location();

  /// Obtém detalhes completos da rota incluindo distância e duração da Directions API
  Future<Map<String, dynamic>> getRouteDetails({
    required LatLng startPoint,
    required LatLng endPoint,
  }) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${startPoint.latitude},${startPoint.longitude}&destination=${endPoint.latitude},${endPoint.longitude}&key=$_googleMapsApiKey&language=pt-BR';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final routes = json['routes'] as List;

        if (routes.isEmpty) {
          return {'distance': 0, 'duration': 0, 'polyline': []};
        }

        final route = routes[0];
        final legs = route['legs'] as List;

        if (legs.isEmpty) {
          return {'distance': 0, 'duration': 0, 'polyline': []};
        }

        // Extrai distância total em metros
        int totalDistance = 0;
        int totalDuration = 0;

        for (final leg in legs) {
          totalDistance += leg['distance']['value'] as int;
          totalDuration += leg['duration']['value'] as int;
        }

        // Decodifica a polilinha
        final points = _decodePolyline(route['overview_polyline']['points']);

        return {
          'distance': totalDistance,
          'duration': totalDuration,
          'polyline': points,
          'startAddress': legs[0]['start_address'],
          'endAddress': legs[legs.length - 1]['end_address'],
        };
      }
      return {'distance': 0, 'duration': 0, 'polyline': []};
    } catch (e) {
      print('Erro ao obter detalhes da rota: $e');
      return {'distance': 0, 'duration': 0, 'polyline': []};
    }
  }

  /// Obtém a rota entre dois pontos usando o Google Maps Directions API
  /// Retorna uma lista de LatLng que representa os pontos da rota
  Future<List<LatLng>> getRoute({
    required LatLng startPoint,
    required LatLng endPoint,
  }) async {
    try {
      final details = await getRouteDetails(
        startPoint: startPoint,
        endPoint: endPoint,
      );

      final polyline = details['polyline'] as List<LatLng>;
      return polyline;
    } catch (e) {
      print('Erro ao obter rota: $e');
      return [];
    }
  }

  /// Decodifica a polilinha do Google Maps
  List<LatLng> _decodePolyline(String polyline) {
    final List<LatLng> polylineCoordinates = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int result = 0;
      int shift = 0;
      int b;

      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;

      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polylineCoordinates;
  }

  /// Calcula a distância aproximada entre dois pontos em metros
  /// usando a fórmula de Haversine
  double calculateDistance({
    required LatLng startPoint,
    required LatLng endPoint,
  }) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(endPoint.latitude - startPoint.latitude);
    final dLng = _degreesToRadians(endPoint.longitude - startPoint.longitude);

    final a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(startPoint.latitude)) *
            math.cos(_degreesToRadians(endPoint.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2));

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distanceKm = earthRadiusKm * c;

    return distanceKm * 1000; // Retorna em metros
  }

  /// Obtém a localização atual do dispositivo
  Future<LatLng?> getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        return LatLng(locationData.latitude!, locationData.longitude!);
      }
      return null;
    } catch (e) {
      print('Erro ao obter localização: $e');
      return null;
    }
  }

  /// Inicia o serviço de localização em tempo real
  Stream<LatLng> getLocationUpdates() {
    return _location.onLocationChanged.map(
      (locationData) => LatLng(locationData.latitude!, locationData.longitude!),
    );
  }

  /// Converte graus para radianos
  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }
}
