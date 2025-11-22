import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/views/user/home_user_page.dart'; // Ajuste se o caminho de volta for outro

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInitialLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Botão Voltar ---
            Row(
              children: [
                CustomVoltarTextButtom(pageToBack: const HomeUserPage()),
              ],
            ),
            const SizedBox(height: 20),

            // --- 2. Logo e Título Principal ---
            Center(
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00C950), Color(0xFF2B7FFF)],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.recycling, // Ícone similar ao da imagem
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Right EcoPoints',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A63E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Conectando cidadãos, administração e comércio para um futuro mais sustentável',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 24),

            // --- 3. Card "Nossa Missão" (Gradiente) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00C950), Color(0xFF2B7FFF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.track_changes, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Nossa Missão',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Facilitar e incentivar o descarte correto de resíduos através de tecnologia, gamificação e parcerias com o comércio local, promovendo uma cidade mais limpa e sustentável para todos.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 4. Seção "Por que é Importante?" ---
            const Text(
              'Por que é Importante?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildImportanceCard(
              icon: Icons.eco_outlined,
              color: Colors.green,
              title: 'Meio Ambiente',
              description:
                  'Reduz a poluição e preserva recursos naturais para as futuras gerações',
            ),
            const SizedBox(height: 12),
            _buildImportanceCard(
              icon: Icons.people_outline,
              color: Colors.blue,
              title: 'Comunidade',
              description:
                  'Fortalece a consciência coletiva e o engajamento cidadão',
            ),
            const SizedBox(height: 12),
            _buildImportanceCard(
              icon: Icons.favorite_border,
              color: Colors.purple,
              title: 'Qualidade de Vida',
              description:
                  'Cria uma cidade mais limpa e saudável para todos os moradores',
            ),
            const SizedBox(height: 24),

            // --- 5. Seção "Como Funciona" ---
            const Text(
              'Como Funciona',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Um sistema integrado que conecta todos os envolvidos',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 20),
            _buildStepRow(
              number: '1',
              color: const Color(0xFF00C950),
              title: 'Registre seu Descarte',
              description:
                  'Informe os tipos e quantidade de resíduos que você vai descartar',
            ),
            _buildStepRow(
              number: '2',
              color: const Color(0xFF2B7FFF),
              title: 'Receba seu Código QR',
              description:
                  'Um código único é gerado para identificar seu descarte',
            ),
            _buildStepRow(
              number: '3',
              color: const Color(0xFFA855F7),
              title: 'Leve ao Ponto de Coleta',
              description: 'Apresente o código no ponto de coleta mais próximo',
            ),
            _buildStepRow(
              number: '4',
              color: const Color(0xFFEAB308),
              title: 'Ganhe Pontos e Cupons',
              description:
                  'Acumule pontos, desbloqueie conquistas e troque por cupons em lojas parceiras',
              isLast: true,
            ),
            const SizedBox(height: 24),

            // --- 6. Seção "Parceiros Oficiais" ---
            const Text(
              'Parceiros Oficiais',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Estabelecimentos que apoiam o programa e oferecem benefícios aos usuários',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 24),

            // --- 7. Card "Mais Informações" (Fundo Claro) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4), // Verde bem claro
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: Color(0xFF15803D)),
                      SizedBox(width: 8),
                      Text(
                        'Mais Informações',
                        style: TextStyle(
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dúvidas ou sugestões sobre o projeto? Entre em contato conosco!',
                    style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  _buildContactRow(
                    Icons.email_outlined,
                    'E-mail:',
                    'contato@rightecopoints.com.br',
                  ),
                  const SizedBox(height: 8),
                  _buildContactRow(
                    Icons.phone_android,
                    'Telefone:',
                    '(11) 3000-0000',
                  ),
                  const SizedBox(height: 8),
                  _buildContactRow(
                    Icons.language,
                    'Site:',
                    'www.rightecopoints.com.br',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 8. Rodapé ---
            const Text(
              'Right EcoPoints © 2025 - Todos os direitos reservados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Text(
              'Versão 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildImportanceCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 0, // O design parece ter borda ou sombra muito suave
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF717182), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required Color color,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF717182),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
