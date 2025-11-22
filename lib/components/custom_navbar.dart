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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo deve ocupar tudo, inclusive atrás da barra
      extendBody: true,
      body: Stack(
        children: [
          // CAMADA 1: Página Atual
          Positioned.fill(child: widget.items[_selectedIndex].page),

          // CAMADA 2: Barra de Navegação Dinâmica
          Positioned(
            left: 10,
            right: 10,
            bottom: 0, // 1. Cole no fundo da tela
            child: SafeArea(
              // 2. O SafeArea empurra pra cima SE tiver barra de gestos
              child: Container(
                // 3. Adicione a margem "flutuante" aqui
                margin: const EdgeInsets.only(bottom: 20),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(110, 0, 0, 0),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? const Color(0xFF00A63E)
                                : Colors.grey,
                            size: 28,
                          ),
                          if (isSelected)
                            Text(
                              '●',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF00A63E),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
