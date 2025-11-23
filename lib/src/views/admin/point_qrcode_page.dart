import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PointQrCodePage extends StatelessWidget {
  final CollectPointModel point;

  const PointQrCodePage({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code do Ponto'),
        backgroundColor: const Color(0xff00A63E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Card com informações do ponto
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0x20000000)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 48,
                          color: Color(0xff00A63E),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          point.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff00A63E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${point.address.street}, ${point.address.number}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${point.address.neighborhood} - ${point.address.city}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Card com o QR Code
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0x20000000)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          'QR Code de Identificação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: QrImageView(
                            data: point.qrCodeId,
                            version: QrVersions.auto,
                            size: 280.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Usuários devem escanear este código\npara registrar descartes neste ponto',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Informações sobre tipos de lixo aceitos
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0x20000000)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipos de lixo aceitos:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: point.trashTypes.map((type) {
                            return Chip(
                              label: Text(type),
                              backgroundColor: const Color(0xffF0FDF4),
                              labelStyle: const TextStyle(
                                color: Color(0xff00A63E),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão para voltar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff00A63E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
