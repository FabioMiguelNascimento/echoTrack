import 'package:flutter/material.dart';

/// Este é o novo widget que recria o design da imagem.
class CustomCheckboxTile extends StatelessWidget {
  final String title;
  final Color color;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckboxTile({
    super.key,
    required this.title,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Espaçamento entre os cards
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        // Faz a linha inteira ser clicável
        onTap: () {
          onChanged(!value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // Adiciona uma borda sutil, como na imagem
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              // 1. O quadrado colorido da esquerda
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),

              // 2. O Título (ocupa o espaço disponível)
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

              // 3. A Checkbox customizada
              Checkbox(
                value: value,
                onChanged: onChanged,
                // Arredonda os cantos da checkbox
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                // Define a cor de fundo quando está marcada
                activeColor: Colors.blue, // Ou a cor que preferir
              ),
            ],
          ),
        ),
      ),
    );
  }
}
