import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/viewmodels/user/user_viewmodel.dart'; // Para pegar nome do usuário logado
import 'package:provider/provider.dart';

class PointDetailsPage extends StatefulWidget {
  // A página só recebe o ID
  final String pointId;
  final String pointName; // Opcional, para exibir no título antes de carregar

  const PointDetailsPage({
    super.key,
    required this.pointId,
    required this.pointName,
  });

  @override
  State<PointDetailsPage> createState() => _PointDetailsPageState();
}

class _PointDetailsPageState extends State<PointDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carrega os detalhes do ponto (se já não estiver selecionado no VM)
      context.read<PontosViewmodel>().selectPoint(widget.pointId);
      // Carrega os comentários
      context.read<PontosViewmodel>().loadFeedbacks(widget.pointId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vmPontos = context.watch<PontosViewmodel>();
    final vmUser = context
        .read<UserViewmodel>(); // Para pegar quem está comentando

    // Pega o ponto selecionado do VM
    final ponto = vmPontos.selectedPoint;

    if (ponto == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return CustomInitialLayout(
      child: Column(
        children: [
          // 1. Cabeçalho e Botão Voltar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                CustomVoltarTextButtom(), // Seu componente de voltar
              ],
            ),
          ),
          Text(
            ponto.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A63E),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 30),

          // 2. Conteúdo Rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Card de Endereço ---
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
                            "${ponto.address.street}, ${ponto.address.number}",
                          ),
                          Text(
                            "${ponto.address.neighborhood} - ${ponto.address.city}/${ponto.address.state}",
                          ),
                          Text("CEP: ${ponto.address.postal}"),
                          const SizedBox(height: 12),
                          const Text(
                            "Tipos aceitos:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 8,
                            children: ponto.trashTypes
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

                  const SizedBox(height: 24),
                  const Text(
                    "Comentários e Feedback",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),

                  // --- Lista de Comentários ---
                  if (vmPontos.feedbacks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "Seja o primeiro a avaliar!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vmPontos.feedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = vmPontos.feedbacks[index];
                        return Card(
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  feedback.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (vmUser.currentUser?.uid == feedback.userId)
                                  TextButton(
                                    onPressed: () {
                                      vmPontos.delFeedbackVM(
                                        vmUser.currentUser!.uid,
                                        ponto.id!,
                                        feedback,
                                      );
                                    },
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(feedback.comment),
                                const SizedBox(height: 4),
                                Text(
                                  "${feedback.date.day}/${feedback.date.month}/${feedback.date.year}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // Espaço extra para não ficar atrás do input
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Input de Comentário (Fixo na parte inferior)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: vmPontos.commentController,
                    decoration: InputDecoration(
                      hintText: "Escreva sua avaliação...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: vmPontos.isLoading
                      ? null
                      : () async {
                          // Pega dados do usuário logado para salvar no comentário
                          final userName = vmUser.currentUserName;
                          final userId = vmUser.currentUser?.uid ?? '';

                          if (userId.isNotEmpty) {
                            await vmPontos.sendFeedback(
                              widget.pointId,
                              userId,
                              userName,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Erro: Usuário não identificado.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: vmPontos.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Color(0xFF00A63E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
