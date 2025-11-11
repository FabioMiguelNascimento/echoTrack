// Libs
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Pages
import 'package:g1_g2/src/views/admin/home_admin_page.dart';
import 'package:g1_g2/src/views/admin/welcome_admin_page.dart';
import 'package:g1_g2/src/views/auth/login_page.dart';
import 'package:g1_g2/src/views/store/welcome_store_page.dart';
import 'package:g1_g2/src/views/user/home_user_page.dart';
import 'package:g1_g2/src/views/user/welcome_user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Classe que seleciona a página que será exibida ao abrir o app
class HomeSelector extends StatelessWidget {
  final String userType;

  const HomeSelector({super.key, required this.userType});

  Future<bool> _hasSeenWelcome(String uid, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenWelcome_$userType-$uid') ?? false;
  }

  Future<void> _setHasSeenWelcome(String uid, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome_$userType-$uid', true);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return FutureBuilder<bool>(
      future: _hasSeenWelcome(user.uid, userType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          final hasSeen = snapshot.data!;
          if (!hasSeen) {
            // Marcar como visto e mostrar Welcome
            _setHasSeenWelcome(user.uid, userType);
            if (userType == 'admin') {
              return WelcomeAdminPage();
            } else if (userType == 'store') {
              return const WelcomeStorePage();
            } else {
              return WelcomeUserPage(uid: user.uid, userType: userType);
            }
          } else {
            // Já viu, ir direto para Home
            if (userType == 'admin') {
              return const HomeAdminPage();
            } else if (userType == 'store') {
              // return const HomeStorePage();
            } else {
              return const HomeUserPage();
            }
          }
        } else {
          return const LoginPage();
        }
        throw Error();
      },
    );
  }
}