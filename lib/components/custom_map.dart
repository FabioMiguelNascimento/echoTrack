import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:g1_g2/src/providers/route_provider.dart';
import 'package:g1_g2/src/utils/map_controller.dart';

class MapWidget extends StatefulWidget {
  final List<CollectPointModel> collectPoints;
  final Function(CollectPointModel)? onMarkerTap;

  const MapWidget({super.key, this.collectPoints = const [], this.onMarkerTap});

  // Permite chamar a ação de seguir rota a partir da lista/detalhes
  static _MapWidgetState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<_MapWidgetState>();
    return state;
  }

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  // Função para seguir rota até o ponto de coleta (usada no InfoWindow)
  Future<void> _handleFollowRoute(CollectPointModel point) async {
    if (point.address.cords != null) {
      try {
        final lat = double.parse(point.address.cords!.lat);
        final lon = double.parse(point.address.cords!.lon);
        final destino = LatLng(lat, lon);

        final routeProvider = context.read<RouteProvider>();
        await routeProvider.getCurrentLocation();
        final origem = routeProvider.currentLocation;

        if (origem != null) {
          _showRouteLoadingDialog();
          await routeProvider.fetchRoute(startPoint: origem, endPoint: destino);
          if (mounted) {
            Navigator.of(context).pop();
          }
          _updateRouteOnMap(routeProvider);
        }
      } catch (e) {
        print('Erro ao seguir rota: $e');
      }
    }
  }

  // Método público para seguir rota a partir da lista/detalhes
  Future<void> followRouteToPoint(CollectPointModel point) async {
    await _handleMarkerTap(point);
  }

  static const LatLng _initialLatLng = LatLng(
    -29.6391109131419,
    -50.78701746008162,
  );

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Marker> _routeMarkers = {};
  Set<Polyline> _polylines = {};
  LatLng? _selectedDestination;
  CollectPointModel? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _createMarkers();
    // Registra a callback de seguir rota para uso global
    MapController.registerFollowCallback((followRouteToPoint, context) async {
      // context.read<RouteProvider>().fetchRoute(
      //   startPoint: LatLng(1221, 1221),
      //   endPoint: LatLng(1221, 1221),
      // );
    }, context);
  }
  //   @override
  // void initState() {
  //   super.initState();
  //   _createMarkers();
  //   // Registra a callback de seguir rota para uso global
  //   MapController.registerFollowCallback((followRouteToPoint, context) {
  //     context.read<RouteProvider>.followRouteToPoint(followRouteToPoint);
  //   }
  //   context
  //   )
  // }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
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
                if (widget.onMarkerTap != null) {
                  widget.onMarkerTap!(point);
                }
                _handleMarkerTap(point);
              },
            ),
          );
        } catch (e) {
          print('Erro ao criar marker para ${point.name}: $e');
        }
      }
    }
    // ...existing code...

    setState(() {
      _markers = markers;
    });

    if (markers.isNotEmpty && _mapController != null) {
      _fitMarkersInView();
    }
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

  Future<void> _handleMarkerTap(CollectPointModel point) async {
    _selectedPoint = point;
    if (point.address.cords != null) {
      try {
        final lat = double.parse(point.address.cords!.lat);
        final lon = double.parse(point.address.cords!.lon);
        _selectedDestination = LatLng(lat, lon);

        if (mounted) {
          final routeProvider = context.read<RouteProvider>();

          if (routeProvider.currentLocation == null) {
            await routeProvider.getCurrentLocation();
          }

          final startLocation = routeProvider.currentLocation;

          if (startLocation != null) {
            _showRouteLoadingDialog();

            await routeProvider.fetchRoute(
              startPoint: startLocation,
              endPoint: _selectedDestination!,
            );

            if (mounted) {
              Navigator.of(context).pop();
            }

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

    // Sempre mostra o BottomSheet se a rota foi calculada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (routeProvider.currentRoute != null && _selectedPoint != null) {
        _showRouteDetailsBottomSheet(
          routeProvider.currentRoute!,
          _selectedPoint!,
        );
      }
    });
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

  void _showRouteDetailsBottomSheet(dynamic route, CollectPointModel point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.8,
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
                    Text(
                      'Rota para ${point.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildRouteDetailCard(
                      'Distância Total',
                      '${(route.distanceInMeters / 1000).toStringAsFixed(2)} km',
                      Icons.directions,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildRouteDetailCard(
                      'Tempo Estimado',
                      _formatDuration(route.estimatedDuration),
                      Icons.schedule,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildRouteDetailCard(
                      'Tipo de Lixo',
                      point.trashTypes.join(', '),
                      Icons.delete,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildRouteDetailCard(
                      'Status',
                      point.isActive ? 'Ativo' : 'Inativo',
                      Icons.info,
                      point.isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _clearRoute();
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _startFollowingRoute(point);
                            },
                            icon: const Icon(Icons.navigation),
                            label: const Text('Seguir Rota'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildRouteDetailCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
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

  void _startFollowingRoute(CollectPointModel point) {
    final routeProvider = context.read<RouteProvider>();
    if (routeProvider.currentRoute != null &&
        routeProvider.currentRoute!.polylinePoints.isNotEmpty) {
      // Centraliza a câmera na rota
      routeProvider.animateToLocation(
        routeProvider.currentRoute!.polylinePoints.first,
      );
      setState(() {
        _polylines = routeProvider.polylines;
        _routeMarkers = routeProvider.markers;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seguindo rota para ${point.name}...'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _routeMarkers.clear();
      _selectedDestination = null;
      _selectedPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
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
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),
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
    // Limpa registro no MapController para evitar callbacks para widget descartado
    MapController.clear();
    super.dispose();
  }
}
