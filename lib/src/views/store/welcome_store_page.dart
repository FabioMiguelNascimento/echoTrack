import 'package:flutter/material.dart';

class WelcomeStorePage extends StatelessWidget {
  const WelcomeStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(child: Text('Bem-vindo(a), Parceiro(a)!')),
        ),
      ),
    );
  }
}
