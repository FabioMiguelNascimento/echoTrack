import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final List<CollectPointModel> collectPoints;
  final Function(CollectPointModel)? onMarkerTap;
  
  const MapWidget({
    super.key, 
    this.collectPoints = const [],
    this.onMarkerTap,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const LatLng _initialLatLng = LatLng(
    -29.6391109131419,
    -50.78701746008162,
  );

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

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
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _initialLatLng, zoom: 13),
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      mapToolbarEnabled: false,
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
        if (_markers.isNotEmpty) {
          Future.delayed(Duration(milliseconds: 500), () {
            _fitMarkersInView();
          });
        }
      },
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
