import 'package:floating_navbar/floating_navbar.dart';
import 'package:floating_navbar/floating_navbar_item.dart';
import 'package:flutter/material.dart';

class NavbarItem {
  final IconData icon;
  final Widget page;
  final String title;

  NavbarItem({required this.icon, required this.page, required this.title});
}

class Navbar extends StatefulWidget {
  final List<NavbarItem> items;

  const Navbar({super.key, required this.items});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {

  @override
  Widget build(BuildContext context) {
    return FloatingNavBar(
      resizeToAvoidBottomInset: false,
      color: Colors.green,
      selectedIconColor: Colors.white,
      unselectedIconColor: Colors.white.withOpacity(0.6),
      items: widget.items.map((item) => FloatingNavBarItem(
        iconData: item.icon,
        page: item.page,
        title: item.title,
      )).toList(),
      horizontalPadding: 10.0,
      hapticFeedback: true,
      showTitle: true,
      scrollPhysics: const NeverScrollableScrollPhysics(),
    );
  }
}
