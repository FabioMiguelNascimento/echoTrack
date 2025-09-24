import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget{
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seja bem vindo!")),
      body: Center(
        child: SizedBox(
          width: 250,
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Email"),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Senha"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FilledButton(onPressed: () {}, child: const Text("Login")),
                  OutlinedButton(onPressed: () {}, child: const Text("Login com Google"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}