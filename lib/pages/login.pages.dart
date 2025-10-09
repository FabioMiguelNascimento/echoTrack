import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
            tileMode: TileMode.mirror,
          ),
        ),
        child: Center(
          child: Container(
            height: 500,
            width: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xffFFFFFF),
              border: Border.all(
                width: 1.0,
                color: const Color.fromARGB(26, 0, 0, 0),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xffFFFFFF),
                    border: Border.all(
                      width: 1.0,
                      color: const Color.fromARGB(26, 0, 0, 0),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 90,
                        child: Center(
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          "Right EcoPoints",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xff0A0A0A),
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          "Facilite a coleta de lixo sustentável",
                          style: TextStyle(
                            color: Color(0xff717182),
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xffFFFFFF),
                    border: Border.all(
                      width: 1.0,
                      color: const Color.fromARGB(26, 0, 0, 0),
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xffFFFFFF),
                    border: Border.all(
                      width: 1.0,
                      color: const Color.fromARGB(26, 0, 0, 0),
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
