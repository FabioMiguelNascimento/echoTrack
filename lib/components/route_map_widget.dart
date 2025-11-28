import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/providers/route_provider.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

class RouteMapWidget extends StatefulWidget {
  final List<CollectPointModel> collectPoints;
  final Function(CollectPointModel)? onMarkerTap;
  final bool showRouteDetails;

  const RouteMapWidget({
    super.key,
    this.collectPoints = const [],
    this.onMarkerTap,
    this.showRouteDetails = true,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  static const LatLng _initialLatLng = LatLng(
    -29.6391109131419,
    -50.78701746008162,
  );

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Marker> _routeMarkers = {};
  Set<Polyline> _polylines = {};
  LatLng? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(RouteMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectPoints != widget.collectPoints) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    final markers = <Marker>{};

    for (final point in widget.collectPoints) {
      if (point.address.cords != null && point.id != null) {
        try {
          final lat = double.parse(point.address.cords!.lat);
          final lon = double.parse(point.address.cords!.lon);

          markers.add(
            Marker(
              markerId: MarkerId(point.id!),
              position: LatLng(lat, lon),
              infoWindow: InfoWindow(
                title: point.name,
                snippet: point.isActive
                    ? '✅ Ativo - ${point.trashTypes.length} tipos de lixo'
                    : '❌ Inativo',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                point.isActive
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueRed,
              ),
              onTap: () {
                _handleMarkerTap(point);
              },
            ),
          );
        } catch (e) {
          print('Erro ao criar marker para ${point.name}: $e');
        }
      }
    }

    setState(() {
      _markers = markers;
    });

    if (markers.isNotEmpty && _mapController != null) {
      _fitMarkersInView();
    }
  }

  Future<void> _handleMarkerTap(CollectPointModel point) async {
    if (widget.onMarkerTap != null) {
      widget.onMarkerTap!(point);
    }

    // Obtém a localização do ponto selecionado
    if (point.address.cords != null) {
      try {
        final lat = double.parse(point.address.cords!.lat);
        final lon = double.parse(point.address.cords!.lon);
        _selectedDestination = LatLng(lat, lon);

        // Usa o RouteProvider para obter a rota
        if (mounted) {
          final routeProvider = context.read<RouteProvider>();

          // Obtém a localização atual se ainda não tiver
          if (routeProvider.currentLocation == null) {
            await routeProvider.getCurrentLocation();
          }

          final startLocation = routeProvider.currentLocation;

          if (startLocation != null) {
            // Mostra loading
            _showRouteLoadingDialog();

            // Busca a rota
            await routeProvider.fetchRoute(
              startPoint: startLocation,
              endPoint: _selectedDestination!,
            );

            // Fecha o loading
            if (mounted) {
              Navigator.of(context).pop();
            }

            // Atualiza os marcadores e polilinhas no mapa
            _updateRouteOnMap(routeProvider);
          }
        }
      } catch (e) {
        print('Erro ao processar toque no marcador: $e');
      }
    }
  }

  void _updateRouteOnMap(RouteProvider routeProvider) {
    setState(() {
      _polylines = routeProvider.polylines;
      _routeMarkers = routeProvider.markers;
    });

    // Mostra detalhes da rota se configurado
    if (widget.showRouteDetails && routeProvider.currentRoute != null) {
      _showRouteDetailsBottomSheet(routeProvider.currentRoute!);
    }
  }

  void _showRouteLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Calculando rota...'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRouteDetailsBottomSheet(dynamic route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          maxChildSize: 0.7,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador de drag
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Detalhes da Rota',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildRouteDetailItem(
                      'Distância',
                      '${(route.distanceInMeters / 1000).toStringAsFixed(2)} km',
                      Icons.directions,
                    ),
                    const SizedBox(height: 12),
                    _buildRouteDetailItem(
                      'Tempo Estimado',
                      _formatDuration(route.estimatedDuration),
                      Icons.schedule,
                    ),
                    const SizedBox(height: 12),
                    _buildRouteDetailItem(
                      'Origem',
                      route.startAddress,
                      Icons.location_on,
                    ),
                    const SizedBox(height: 12),
                    _buildRouteDetailItem(
                      'Destino',
                      route.endAddress,
                      Icons.location_on,
                    ),
                    const SizedBox(height: 24),
                    // Botões de ação
                    Row(
                      children: [
                        // Botão Recusar
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _clearRoute();
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Recusar'),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botão Aceitar
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _startFollowingRoute();
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Aceitar Rota'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRouteDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes} min';
    }
    return '$minutes min';
  }

  void _startFollowingRoute() {
    // Aqui você pode iniciar o rastreamento da rota
    // Por exemplo, iniciar um stream de localização em tempo real
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seguindo rota...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _fitMarkersInView() {
    if (_markers.isEmpty || _mapController == null) return;

    double minLat = 90, maxLat = -90;
    double minLon = 180, maxLon = -180;

    for (final marker in _markers) {
      final pos = marker.position;
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLon) minLon = pos.longitude;
      if (pos.longitude > maxLon) maxLon = pos.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLon),
      northeast: LatLng(maxLat, maxLon),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _routeMarkers.clear();
      _selectedDestination = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _initialLatLng,
            zoom: 13,
          ),
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapToolbarEnabled: false,
          markers: {..._markers, ..._routeMarkers},
          polylines: _polylines,
          onMapCreated: (controller) {
            _mapController = controller;
            if (_markers.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 500), () {
                _fitMarkersInView();
              });
            }
          },
        ),
        // Botão para limpar a rota
        if (_selectedDestination != null)
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _clearRoute,
              backgroundColor: Colors.red,
              child: const Icon(Icons.clear),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
