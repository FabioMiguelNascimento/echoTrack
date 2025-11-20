import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/models/discart_model.dart';
import 'package:g1_g2/src/viewmodels/user/discart_viewmodel.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Carrega o histórico logo após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscartViewmodel>().loadUserHistory();
    });
  }

  // Helper para definir a cor do status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluido':
      case 'concluído':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'pendente':
      default:
        return Colors.orange;
    }
  }

  // Helper para traduzir/formatar o texto do status
  String _formatStatus(String status) {
    if (status == 'concluido') return 'Concluído';
    if (status.isEmpty) return 'Pendente';
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscartViewmodel>(
      builder: (context, vm, child) {
        return CustomInitialLayout(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                // Cabeçalho
                Row(children: [CustomVoltarTextButtom()]),
                const SizedBox(height: 24),
                const Text(
                  'Meus Descartes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 16),

                // Conteúdo: Loading, Erro ou Lista
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (vm.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (vm.errorMessage != null) {
                        return Center(
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (vm.userDiscarts.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum registro de descarte encontrado.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      // Lista de Cards
                      return ListView.separated(
                        itemCount: vm.userDiscarts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final discart = vm.userDiscarts[index];
                          return _buildDiscartCard(discart, vm);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscartCard(DiscartModel discart, DiscartViewmodel vm) {
    final isPending = discart.status == 'pendente';
    final statusColor = _getStatusColor(discart.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha superior: Tipo de Lixo e Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    discart.trashType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A63E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _formatStatus(discart.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Detalhes
            Text(
              'Quantidade: ${discart.aproxQuantity}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            if (discart.observations.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Obs: ${discart.observations}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Botões de Ação (Só aparecem se estiver 'pendente')
            if (isPending) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _confirmAction(
                      context,
                      'Cancelar',
                      'Deseja cancelar este descarte?',
                      () => vm.cancelDiscart(discart.uid!),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _confirmAction(
                      context,
                      'Concluir',
                      'Confirmar que o descarte foi realizado?',
                      () => vm.completeDiscart(discart.uid!),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Concluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A63E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Diálogo de confirmação simples
  void _confirmAction(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: const Color.fromARGB(255, 161, 161, 161),
            width: 1,
          ),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
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
            onPressed: () {
              Navigator.pop(ctx); // Fecha o diálogo
              onConfirm(); // Executa a ação do VM
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
      ),
    );
  }
}
