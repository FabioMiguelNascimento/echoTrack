import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_avancar_text_buttom.dart';
import 'package:g1_g2/src/views/admin/home_admin_page.dart';

class WelcomeAdminPage extends StatelessWidget {
  const WelcomeAdminPage({super.key});

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
          child: SafeArea(
            child: Column(
              children: [
                Text('Bem-vindo, Administrador!'),
                CustomAvancarTextButtom(nextPage: HomeAdminPage()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
