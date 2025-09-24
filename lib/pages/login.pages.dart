import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Login")),
      body: Center(
        child: SizedBox(
          width: 250,
          child: Column(
            spacing: 30,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Entre no app",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Senha",
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FilledButton(
                    onPressed: () {},
                    child: const Text("Login"),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("Login com Google"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
