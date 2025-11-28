import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final String id;
  final LatLng startLocation;
  final LatLng endLocation;
  final String startAddress;
  final String endAddress;
  final List<LatLng> polylinePoints;
  final double distanceInMeters;
  final Duration estimatedDuration;
  final DateTime createdAt;
  final bool isActive;

  RouteModel({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
    required this.polylinePoints,
    required this.distanceInMeters,
    required this.estimatedDuration,
    required this.createdAt,
    this.isActive = true,
  });

  RouteModel copyWith({
    String? id,
    LatLng? startLocation,
    LatLng? endLocation,
    String? startAddress,
    String? endAddress,
    List<LatLng>? polylinePoints,
    double? distanceInMeters,
    Duration? estimatedDuration,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return RouteModel(
      id: id ?? this.id,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      startAddress: startAddress ?? this.startAddress,
      endAddress: endAddress ?? this.endAddress,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'RouteModel(id: $id, startAddress: $startAddress, endAddress: $endAddress, distance: $distanceInMeters m)';
  }
}
