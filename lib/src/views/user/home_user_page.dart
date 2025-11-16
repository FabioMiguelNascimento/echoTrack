import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_map.dart';
import 'package:g1_g2/components/custom_navbar.dart';
import 'package:g1_g2/src/views/user/profile_page.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: MapWidget());
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.green,
      ),
      body: const Center(child: Text('Configurações')),
    );
  }
}

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends State<HomeUserPage> {
  @override
  Widget build(BuildContext context) {
    return Navbar(
      items: [
        NavbarItem(icon: Icons.home, page: const HomeContent(), title: 'Casa'),
        NavbarItem(
          icon: Icons.person,
          page: const ProfilePage(),
          title: 'Perfil',
        ),
        NavbarItem(
          icon: Icons.settings,
          page: const SettingsPage(),
          title: 'Configurações',
        ),
      ],
    );
  }
}
