import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_green_button.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/src/views/user/home_user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeUserPage extends StatelessWidget {
  final String uid;
  final String userType;

  const WelcomeUserPage({super.key, required this.uid, required this.userType});

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
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Bem-vindo(a), \nUsuário(a)!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF008236), fontSize: 24),
          ),
          SizedBox(height: 20),
          CustomGreenButton(
            label: 'Explorar mapa',
            handleClick: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hasSeenWelcome_${userType}_$uid', true);
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeUserPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
