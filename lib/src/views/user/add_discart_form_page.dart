import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';

class AddDiscartFormPage extends StatelessWidget {
  const AddDiscartFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInitialLayout(
      child: Center(child: Text('Form para descartes')),
    );
  }
}
