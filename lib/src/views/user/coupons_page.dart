import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInitialLayout(child: Center(child: Text('Página de cupons')));
  }
}
