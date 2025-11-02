import 'package:flutter/material.dart';

class CustomVoltarTextButtom extends StatelessWidget {
  const CustomVoltarTextButtom({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.only(left: 0, right: 0),
        iconColor: Colors.black,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back),
      label: Text('Voltar', style: TextStyle(color: Colors.black)),
    );
  }
}
