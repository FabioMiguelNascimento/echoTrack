import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_green_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';

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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0x20000000)),
                  ),
                  shadowColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      bottom: 30,
                      right: 20,
                      left: 20,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/logo2.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Right EcoPoints', style: TextStyle(fontSize: 24)),
                        Text(
                          'Facilite a coleta de lixo sustentável',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xff717182),
                          ),
                        ),
                        SizedBox(height: 20),

                        SizedBox(
                          height: 30,
                          width: double.infinity,
                          child: Text('E-mail', style: TextStyle(fontSize: 17)),
                        ),
                        TextField(
                          onChanged: (text) {
                            email = text;
                          },
                          cursorColor: Color(0xff00A63E),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'seu@email.com',
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color(0xff00A63E),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(style: BorderStyle.none),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          height: 30,
                          width: double.infinity,
                          child: Text('Senha', style: TextStyle(fontSize: 17)),
                        ),
                        TextField(
                          onChanged: (text) {
                            password = text;
                          },
                          obscureText: true,
                          cursorColor: Color(0xff00A63E),
                          decoration: InputDecoration(
                            hintText: 'Sua senha',
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color(0xff00A63E),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(style: BorderStyle.none),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        CustomGreenButton(
                          handleClick: () {
                            if (email == 'vitor@email.com' &&
                                password == '1234') {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/home');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
