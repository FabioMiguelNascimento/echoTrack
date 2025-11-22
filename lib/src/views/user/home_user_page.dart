import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_navbar.dart';
import 'package:g1_g2/src/views/user/add_discart_form_page.dart';
import 'package:g1_g2/src/views/user/coupons_page.dart';
import 'package:g1_g2/src/views/user/user_dashboard.dart';

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
        NavbarItem(
          icon: Icons.home_rounded,
          page: const UserDashboardPage(),
          title: 'Casa',
        ),
        NavbarItem(
          icon: Icons.add_box_rounded,
          page: const AddDiscartFormPage(),
          title: 'Descartar',
        ),
        NavbarItem(
          icon: Icons.card_giftcard_rounded,
          page: const CouponsPage(),
          title: 'Cupons',
        ),
      ],
    );
  }
}
