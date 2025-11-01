import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_green_button.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/views/admin/add_collect_point_form_page.dart';
import 'package:g1_g2/src/views/admin/welcome_admin_page.dart';
import 'package:g1_g2/src/views/auth/login_page.dart';
import 'package:provider/provider.dart';

class HomeAdminPage extends StatelessWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInitialLayout(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Row(
              children: [
                CustomVoltarTextButtom(pageToBack: WelcomeAdminPage()),
              ],
            ),
          ),
          Text(
            'Pontos de coleta do município',
            style: TextStyle(fontSize: 18, color: Color(0xFF0A0A0A)),
          ),
          SizedBox(height: 25),
          Text(
            'Todos os pontos de coleta existentes no município',
            style: TextStyle(fontSize: 18, color: Color(0xFF717182)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25),
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
          CustomGreenButton(
            handleClick: () {
              // Use push so that the form can pop back to this page after saving
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCollectPointFormPage(),
                ),
              );
            },
            label: 'Cadastrar novo ponto',
          ),
        ],
      ),
    );
  }
}
