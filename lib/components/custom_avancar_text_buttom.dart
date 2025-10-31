import 'package:flutter/material.dart';

class CustomAvancarTextButtom extends StatelessWidget {
  final Widget nextPage;

  const CustomAvancarTextButtom({super.key, required this.nextPage});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.only(left: 0, right: 0),
        iconColor: Colors.black,
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      icon: Icon(Icons.arrow_forward),
      label: Text('Avançar', style: TextStyle(color: Colors.black)),
    );
  }
}
