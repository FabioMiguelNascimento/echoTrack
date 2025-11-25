import 'package:flutter/material.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/views/auth/login_page.dart';
import 'package:provider/provider.dart';

class LogoutConfirmation extends StatefulWidget {
  const LogoutConfirmation({super.key});

  @override
  State<LogoutConfirmation> createState() => _LogoutConfirmationState();
}

class _LogoutConfirmationState extends State<LogoutConfirmation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: const Color.fromARGB(255, 161, 161, 161),
          width: 1,
        ),
      ),
      title: const Text('Confirmar Saída'),
      content: const Text(
        'Tem certeza que deseja sair do aplicativo?',
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            // Cor do texto
            foregroundColor: Colors.black87,
            // Cor de fundo
            backgroundColor: Colors.white,
            // Altura do botão
            minimumSize: const Size(0, 50),
            // Borda (cor e largura)
            side: BorderSide(color: Colors.grey.shade300, width: 1),
            // Cantos arredondados (igual aos seus TextFields)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Não'),
        ),
        ElevatedButton(
          onPressed: () async {
            await context.read<AuthRepository>().signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            // Cor do fundo (verde da sua app)
            backgroundColor: const Color(0xff00A63E),
            // Cor do texto e ícone (branco)
            foregroundColor: Colors.white,
            // Cor do fundo quando desabilitado (loading)
            disabledBackgroundColor: const Color(0xff00A63E),
            // Cor do texto/ícone quando desabilitado
            disabledForegroundColor: Colors.white,
            // Altura do botão
            minimumSize: const Size(0, 50),
            // Cantos arredondados
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: Colors.transparent,
          ),
          child: const Text('Sim'),
        ),
      ],
    );
  }
}
