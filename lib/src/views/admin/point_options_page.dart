// src/views/admin/point_details_page.dart
import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_dashboard_card.dart'; // <-- Importe o card
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';
import 'package:g1_g2/src/views/admin/home_admin_page.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/views/admin/edit_collect_point_form_page.dart';

class PointOptionsPage extends StatelessWidget {
  // A página recebe o ponto de coleta como parâmetro
  final CollectPointModel point;

  const PointOptionsPage({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return CustomInitialLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // Botão "Voltar" simples
            Row(
              children: [CustomVoltarTextButtom(pageToBack: HomeAdminPage())],
            ),
            const SizedBox(height: 24),

            // Título (nome do ponto)
            Text(
              point.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0A0A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtítulo
            const Text(
              'Verifique a condição e status do ponto de coleta',
              style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Card 1 (Verde)
            CustomDashboardCard(
              color: const Color(0xFF00A63E), // Verde
              icon: Icons.people_outline_rounded,
              title: 'O que a população diz',
              subtitle: '0 - Observações',
              onTap: () {
                // TODO: Navegar para a tela de observações
              },
            ),

            const SizedBox(height: 16),

            // Card 3 (Laranja) - Editar
            CustomDashboardCard(
              color: const Color.fromARGB(255, 230, 127, 9), // Laranja
              icon: Icons.info_outline_rounded,
              title: 'Editar informações',
              subtitle: 'Edite as informações básicas do ponto',
              onTap: () async {
                // Navega para a tela de edição e aguarda resultado
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) =>
                        EditCollectPointFormPage(point: point),
                  ),
                );
                if (result == true) {
                  // Recarrega a lista no ViewModel registrado globalmente
                  final vm = context.read<PontosViewmodel>();
                  await vm.refresh();
                }
              },
            ),

            const SizedBox(height: 16),

            // Card 3 (Vermelho)
            CustomDashboardCard(
              color: const Color.fromARGB(255, 255, 0, 0), // Azul
              icon: Icons.dangerous_outlined,
              title: 'Excluir ponto',
              subtitle: 'Excluír ponto permanentemente',
              onTap: () async {
                // Confirmação antes de excluir
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirmar exclusão'),
                      content: const Text(
                        'Tem certeza que deseja excluir este ponto de coleta? Esta ação não pode ser desfeita.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Não'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Sim'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  final vm = context.read<PontosViewmodel>();
                  if (point.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ID do ponto não disponível.'),
                      ),
                    );
                    return;
                  }

                  await vm.deleteCollectPoint(point.id!);

                  if (vm.errorMessage != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ponto excluído com sucesso'),
                      ),
                    );
                    // Volta para a tela anterior (lista)
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
