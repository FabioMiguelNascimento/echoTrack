import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/views/admin/welcome_admin_page.dart';
import 'package:g1_g2/src/views/auth/login_page.dart';
import 'package:provider/provider.dart';

class HomeAdminPage extends StatelessWidget {
  const HomeAdminPage({super.key});

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
                CustomVoltarTextButtom(pageToBack: WelcomeAdminPage()),
                Text('Menu do Administrador!'),
                ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthRepository>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
