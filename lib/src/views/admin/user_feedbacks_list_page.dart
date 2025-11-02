import 'package:flutter/material.dart';

// -----------------------------------------------------------------
// 1. INÍCIO DO CÓDIGO DA PÁGINA (FeedbackListPage)
// -----------------------------------------------------------------

class UserFeedbacksListPage extends StatelessWidget {
  const UserFeedbacksListPage({super.key});

  // --- Dados Estáticos para a Lista ---
  // (Baseado na sua imagem)
  static final List<Map<String, String>> feedbacksEstaticos = [
    {'nome': 'Douglas', 'feedback': 'Impressora não está funcionando'},
    {'nome': 'Douglas', 'feedback': 'Impressora foi roubada'},
    {
      'nome': 'Ana Clara',
      'feedback': 'Ponto de coleta está sempre cheio, sem espaço.',
    },
    {'nome': 'Marcos', 'feedback': 'Não consegui ler o QR Code da máquina.'},
  ];

  // --- Helper Widget para o Card de Feedback ---
  Widget _buildFeedbackCard(Map<String, String> feedback) {
    // Cor verde principal do seu app
    const Color corNome = Color(0xff00A63E);

    return Padding(
      // Espaçamento entre os cards
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 0, // Sem sombra, como na imagem
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          // Borda sutil, opcional (imagem parece ter uma)
          // side: BorderSide(color: Color(0x20000000)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feedback['nome']!,
                style: const TextStyle(
                  color: corNome,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feedback['feedback']!,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo em gradiente, igual ao da outra tela
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Botão Voltar ---
              Row(
                children: [
                  const SizedBox(width: 10), // Ajuste de padding
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      'Voltar',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      // Remove o highlight de clique
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Títulos (Centralizados) ---
              Center(
                child: Text(
                  'O que a população diz',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: Text(
                    'Todos os pontos de coleta existentes no município',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Lista de Feedbacks ---
              Expanded(
                child: ListView.builder(
                  // Padding para a lista não colar nas bordas
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: feedbacksEstaticos.length,
                  itemBuilder: (context, index) {
                    return _buildFeedbackCard(feedbacksEstaticos[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
