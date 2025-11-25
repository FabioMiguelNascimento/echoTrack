// import 'package:flutter/foundation.dart'; // removed debug usage
import 'package:flutter/material.dart';
import 'register_store_page.dart';
// debug seed page removed from UI

class WelcomeStorePage extends StatelessWidget {
  const WelcomeStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        leading: BackButton(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Debug seed removed per production requirement
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xffE6F4EA),
                child: Icon(Icons.store, size: 42, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bem-vindo, Parceiro!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Para começar a utilizar o sistema, você precisa cadastrar sua loja.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.storefront, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('Cadastre sua Loja', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Registre-se e comece a oferecer cupons de desconto'),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('1  Cadastre as informações da sua loja'),
                          Text('2  Crie cupons de desconto atrativos'),
                          Text('3  Aumente seu ranking e atraia mais clientes'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Cadastrar Minha Loja'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterStorePage()));
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Benefícios de ser Parceiro', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('• Atraia clientes engajados com sustentabilidade'),
                      Text('• Destaque sua marca no ranking municipal'),
                      Text('• Fidelize clientes com sistema de cupons'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
