import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF0FDF4),
      body: Center(
        child: SizedBox(
          width: 350,
          height: 600,
          child: Container(
            constraints: BoxConstraints.expand(
              height:
                  Theme.of(context).textTheme.headlineMedium!.fontSize! * 1.1 +
                  200.0,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Column(
                
            ),
          ),
        ),
      ),
    );
  }
}
