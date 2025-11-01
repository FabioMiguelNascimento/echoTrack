import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_green_button.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/src/views/admin/home_admin_page.dart';

class WelcomeAdminPage extends StatelessWidget {
  const WelcomeAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInitialLayout(
      child: Column(
        children: [
          SizedBox(height: 60),
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF00C950), Color(0xff2B7FFF)],
              ),
            ),
            child: Icon(Icons.shield_outlined, size: 60, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Bem-vindo, \nAdministrador!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF008236), fontSize: 24),
          ),
          SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFFB9F8CF), width: 2),
            ),
            shadowColor: Colors.transparent,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store_rounded,
                        size: 30,
                        color: Color(0xFF00A63E),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Administre os pontos\nde coleta',
                        style: TextStyle(
                          fontSize: 19,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Veja os pontos de coleta e ajuste eles conforme a necessidade do município',
                    style: TextStyle(fontSize: 17, color: Color(0xFF717182)),
                  ),
                  SizedBox(height: 30),
                  CustomGreenButton(
                    label: 'Visualizar pontos',
                    handleClick: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeAdminPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
