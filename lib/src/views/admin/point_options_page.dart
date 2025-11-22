import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_dashboard_card.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/views/admin/user_feedbacks_list_page.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/views/admin/edit_collect_point_form_page.dart';

class PointOptionsPage extends StatefulWidget {
  final String pointId;
  const PointOptionsPage({super.key, required this.pointId});

  @override
  State<PointOptionsPage> createState() => _PointOptionsPageState();
}

class _PointOptionsPageState extends State<PointOptionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PontosViewmodel>().selectPoint(widget.pointId);
      context.read<PontosViewmodel>().loadFeedbacks(widget.pointId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vmPoints = context.watch<PontosViewmodel>();

    final point = vmPoints.selectedPoint;

    // 2. Se nenhum ponto estiver selecionado (erro), volta.
    if (point == null) {
      return Scaffold(body: Center(child: Text('Erro: Ponto não selecionado')));
    }
    return CustomInitialLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
        child: Column(
          children: [
            // Botão "Voltar" simples
            Row(children: [CustomVoltarTextButtom()]),
            const SizedBox(height: 12),
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
            // Título (nome do ponto)

            // Subtítulo
            const Text(
              'Verifique a condição do ponto de coleta',
              style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Color(0x20000000)),
                      ),
                      shadowColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Endereço",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${point.address.street}, ${point.address.number}",
                            ),
                            Text(
                              "${point.address.neighborhood} - ${point.address.city}/${point.address.state}",
                            ),
                            Text("CEP: ${point.address.postal}"),
                            const SizedBox(height: 12),
                            const Text(
                              "Tipos aceitos:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Wrap(
                              spacing: 8,
                              children: point.trashTypes
                                  .map(
                                    (type) => Chip(
                                      label: Text(
                                        type,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF00A63E),
                                      padding: EdgeInsets.zero,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Card 1 (Verde)
                    CustomDashboardCard(
                      color: const Color(0xFF00A63E), // Verde
                      icon: Icons.people_outline_rounded,
                      title: 'O que a população diz',
                      subtitle: '${vmPoints.feedbacks.length} - Comentários',
                      onTap: () async {
                        // Navega para a tela de edição e aguarda resultado
                        await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) =>
                                UserFeedbacksListPage(pointId: point.id!),
                          ),
                        );
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
                            builder: (context) => EditCollectPointFormPage(),
                          ),
                        );
                        if (result == true) {
                          // Recarrega a lista no ViewModel registrado globalmente
                          if (context.mounted) {
                            final vm = context.read<PontosViewmodel>();
                            await vm.refresh();
                          }
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
                        final BuildContext localContext = context;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color: const Color.fromARGB(
                                    255,
                                    161,
                                    161,
                                    161,
                                  ),
                                  width: 1,
                                ),
                              ),
                              title: const Text('Confirmar exclusão'),
                              content: const Text(
                                'Tem certeza que deseja excluir este ponto de coleta? Esta ação não pode ser desfeita.',
                              ),
                              actions: [
                                OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  style: OutlinedButton.styleFrom(
                                    // Cor do texto
                                    foregroundColor: Colors.black87,
                                    // Cor de fundo
                                    backgroundColor: Colors.white,
                                    // Altura do botão
                                    minimumSize: const Size(0, 50),
                                    // Borda (cor e largura)
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                    // Cantos arredondados (igual aos seus TextFields)
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Não'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    // Cor do fundo (verde da sua app)
                                    backgroundColor: const Color(0xff00A63E),
                                    // Cor do texto e ícone (branco)
                                    foregroundColor: Colors.white,
                                    // Cor do fundo quando desabilitado (loading)
                                    disabledBackgroundColor: const Color(
                                      0xff00A63E,
                                    ),
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
                          },
                        );

                        if (!localContext.mounted) return;

                        if (confirmed == true) {
                          final vm = localContext.read<PontosViewmodel>();
                          if (point.id == null) {
                            ScaffoldMessenger.of(localContext).showSnackBar(
                              const SnackBar(
                                content: Text('ID do ponto não disponível.'),
                              ),
                            );
                            return;
                          }

                          await vm.deleteCollectPoint(point.id!);

                          if (!localContext.mounted) return;

                          if (vm.errorMessage != null) {
                            ScaffoldMessenger.of(localContext).showSnackBar(
                              SnackBar(content: Text(vm.errorMessage!)),
                            );
                          } else {
                            ScaffoldMessenger.of(localContext).showSnackBar(
                              const SnackBar(
                                content: Text('Ponto excluído com sucesso'),
                              ),
                            );
                            // Volta para a tela anterior (lista)
                            Navigator.of(localContext).pop();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
