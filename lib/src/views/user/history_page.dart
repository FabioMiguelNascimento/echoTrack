import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInitialLayout(child: const Center(child: Text('Historico')));
  }
}
