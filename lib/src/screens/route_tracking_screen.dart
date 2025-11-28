import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/providers/route_provider.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';
import 'package:g1_g2/components/route_map_widget.dart';

/// Exemplo de tela que usa o RouteMapWidget
class RouteTrackingScreen extends StatelessWidget {
  final List<CollectPointModel> collectPoints;

  const RouteTrackingScreen({super.key, required this.collectPoints});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rastreamento de Rotas'), elevation: 0),
      body: ChangeNotifierProvider(
        create: (context) => RouteProvider(),
        child: RouteMapWidget(
          collectPoints: collectPoints,
          onMarkerTap: (point) {
            // Callback quando um marcador é tocado
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ponto selecionado: ${point.name}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          showRouteDetails: true,
        ),
      ),
    );
  }
}
