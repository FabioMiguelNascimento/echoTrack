import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/src/utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:g1_g2/src/views/user/voice_search_points_page.dart';
import 'package:g1_g2/components/custom_map.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/viewmodels/user/user_viewmodel.dart';
import 'package:g1_g2/src/views/extras/about_page.dart';
import 'package:g1_g2/src/views/user/history_page.dart';
import 'package:g1_g2/src/views/user/near_points_page.dart';
import 'package:g1_g2/src/views/user/profile_page.dart';
import 'package:provider/provider.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Garante que os dados do usuário estejam carregados ao abrir a dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewmodel>().loadCurrentUser();
      context.read<PontosViewmodel>().loadCollectPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtém os dados do usuário para exibir o nome
    final vm = context.watch<UserViewmodel>();
    final userName = vm.currentUserName.isNotEmpty
        ? vm.currentUserName
        : 'Usuário';

    return CustomInitialLayout(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),

          child: Column(
            children: [
              // --- 1. Cabeçalho ---
              _buildHeader(context, userName),

              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- 3. Card de Próxima Coleta ---
                        _buildMapCard(),

                        const SizedBox(height: 24),

                        // --- 4. Grid de Ações Rápidas ---
                        const Text(
                          'Ações Rápidas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Usando Wrap ou Column com Rows para o grid
                        _buildActionsGrid(context),

                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader(BuildContext context, String userName) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $userName!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A63E),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Bem-vindo ao Right EcoPoints',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        // Ícone de Busca por voz (pede permissão e abre busca)
        IconButton(
          onPressed: () async {
            final status = await PermissionHelper.requestMicrophonePermission(
              context,
            );
            if (status == PermissionStatus.granted) {
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VoiceSearchPointsPage(),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.mic),
          color: Colors.black87,
        ),
        // Ícone de Perfil (Navega para ProfilePage)
        IconButton(
          onPressed: () async {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
          },
          icon: const Icon(Icons.person_outline_rounded),
          color: Colors.black87,
        ),
        // Ícone de Conf
        IconButton(
          onPressed: () async {
            if (context.mounted) {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AboutPage()));
            }
          },
          icon: const Icon(Icons.question_mark_rounded, size: 20),
          color: Colors.black87,
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    final pontosVm = context.watch<PontosViewmodel>();

    return Container(
      height: 440, // Altura definida para o mapa
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(75, 0, 0, 0),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // ClipRRect é essencial para arredondar as bordas do GoogleMap
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            MapWidget(
              collectPoints: pontosVm.allPoints
                  .where((p) => p.isActive)
                  .toList(),
              onMarkerTap: (point) {
                _showPointDetails(context, point);
              },
            ),

            if (pontosVm.allPoints.isNotEmpty)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xff00A63E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${pontosVm.allPoints.where((p) => p.isActive).length} pontos',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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

  void _showPointDetails(BuildContext context, point) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Color(0xff00A63E), size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff00A63E),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Endereço:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text('${point.address.street}, ${point.address.number}'),
            Text('${point.address.neighborhood} - ${point.address.city}'),
            SizedBox(height: 12),
            Text(
              'Tipos de lixo aceitos:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: point.trashTypes.map<Widget>((type) {
                return Chip(
                  label: Text(type),
                  backgroundColor: Color(0xffF0FDF4),
                  labelStyle: TextStyle(
                    color: Color(0xff00A63E),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
                label: Text('Fechar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00A63E),
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsGrid(BuildContext context) {
    // Grid manual usando Column + Rows para evitar conflitos de scroll
    // com o SingleChildScrollView principal
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.history,
                title: 'Meu Histórico',
                color: const Color(0xFF2563EB),
                textColor: const Color(0xFF2563EB), // Azul
                isOutlined: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.near_me_outlined,
                title: 'Pontos Próximos',
                color: const Color(0xFF0D9488), // Teal
                textColor: const Color(0xFF0D9488),
                isOutlined: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NearPointsPage()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Color textColor,
    Color? bgColor,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isOutlined ? Border.all(color: color) : null,
          boxShadow: [
            if (!isOutlined) // Sombra suave apenas se for preenchido
              BoxShadow(
                color: const Color.fromARGB(75, 0, 0, 0),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutlined ? color : Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
