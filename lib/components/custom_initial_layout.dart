import 'package:flutter/material.dart';

class CustomInitialLayout extends StatelessWidget {
  final Widget child;

  const CustomInitialLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(12.0), child: child),
        ),
      ),
    );
  }
}
