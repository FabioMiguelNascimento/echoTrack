import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/views/user/point_details_page.dart';
import 'package:provider/provider.dart';

import 'package:g1_g2/src/viewmodels/admin/dtos/point_card_data.dart';

class NearPointsPage extends StatefulWidget {
  const NearPointsPage({super.key});

  @override
  State<NearPointsPage> createState() => _NearPointsPageState();
}

class _NearPointsPageState extends State<NearPointsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PontosViewmodel>();
      vm.loadCollectPoints();
    });
  }

  Widget _buildPointCard(PointCardData data) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0x20000000)),
      ),
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          context.read<PontosViewmodel>().selectPoint(data.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PointDetailsPage(pointId: data.id, pointName: data.name),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A63E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      'Mais Informações',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF717182),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PontosViewmodel>(
      builder: (context, vm, child) {
        return CustomInitialLayout(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [CustomVoltarTextButtom()]),
                const SizedBox(height: 12),
                const Text(
                  'Pontos de coleta do município',
                  style: TextStyle(fontSize: 18, color: Color(0xFF0A0A0A)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Todos os pontos de coleta existentes no município',
                  style: TextStyle(fontSize: 18, color: Color(0xFF717182)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Área principal: loading / erro / lista
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (vm.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (vm.errorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            vm.errorMessage ?? 'Erro desconhecido',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else {
                        if (vm.pointCards.isEmpty) {
                          return const Center(
                            child: Text('Nenhum ponto encontrado'),
                          );
                        }
                        return ListView.separated(
                          itemCount: vm.pointCards.length,
                          separatorBuilder: (_, __) => const SizedBox.shrink(),
                          itemBuilder: (context, index) {
                            final PointCardData data = vm.pointCards[index];
                            return _buildPointCard(data);
                          },
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
