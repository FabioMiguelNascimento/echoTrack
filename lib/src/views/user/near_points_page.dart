import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';

class NearPointsPage extends StatelessWidget {
  const NearPointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInitialLayout(child: Center(child: Text('Pontos próximos')));
  }
}
