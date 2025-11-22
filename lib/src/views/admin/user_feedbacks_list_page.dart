import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/feedback_model.dart'; // Verificar e remover
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------
// 1. INÍCIO DO CÓDIGO DA PÁGINA (FeedbackListPage)
// -----------------------------------------------------------------

class UserFeedbacksListPage extends StatefulWidget {
  final String pointId;

  const UserFeedbacksListPage({super.key, required this.pointId});

  @override
  State<UserFeedbacksListPage> createState() => _UserFeedbacksListPageState();
}

class _UserFeedbacksListPageState extends State<UserFeedbacksListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carrega os detalhes do ponto
      context.read<PontosViewmodel>().selectPoint(widget.pointId);

      // Carrega os comntários
      context.read<PontosViewmodel>().loadFeedbacks(widget.pointId);
    });
  }

  // --- Helper Widget para o Card de Feedback ---
  Widget _buildFeedbackCard(FeedbackModel feedback) {
    // Cor verde principal do seu app
    const Color corNome = Color(0xff00A63E);

    return Padding(
      // Espaçamento entre os cards
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Color(0x20000000)),
        ),
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(feedback.userName[0].toUpperCase()),
          ),
          title: Text(
            feedback.userName,
            style: const TextStyle(fontWeight: FontWeight.bold, color: corNome),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feedback.comment),
              const SizedBox(height: 4),
              Text(
                "${feedback.date.day}/${feedback.date.month}/${feedback.date.year}",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmPoints = context.watch<PontosViewmodel>();

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
                  itemCount: vmPoints.feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = vmPoints.feedbacks[index];
                    return _buildFeedbackCard(feedback);
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
