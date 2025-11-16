import 'package:flutter/material.dart';

class CustomVoltarTextButtom extends StatelessWidget {
  final Widget? pageToBack;
  const CustomVoltarTextButtom({super.key, this.pageToBack});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.only(left: 0, right: 0),
        iconColor: Colors.black,
      ),
      onPressed: () {
        if (pageToBack == null) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => pageToBack!),
          );
        }
      },
      icon: Icon(Icons.arrow_back),
      label: Text('Voltar', style: TextStyle(color: Colors.black)),
    );
  }
}
