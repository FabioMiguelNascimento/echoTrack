import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrCodeScannerPage extends StatefulWidget {
  const QrCodeScannerPage({super.key});

  @override
  State<QrCodeScannerPage> createState() => _QrCodeScannerPageState();
}

class _QrCodeScannerPageState extends State<QrCodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<bool> _validateProximity(CollectPointModel point) async {
    try {
      if (point.address.cords == null) {
        print('⚠️ Ponto sem coordenadas - permitindo acesso (modo de compatibilidade)');
        return true;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double pointLat = double.parse(point.address.cords!.lat);
      double pointLon = double.parse(point.address.cords!.lon);

      double distance = _calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        pointLat,
        pointLon,
      );

      print('📍 Localização do usuário: ${currentPosition.latitude}, ${currentPosition.longitude}');
      print('📍 Localização do ponto: $pointLat, $pointLon');
      print('📏 Distância calculada: ${distance.toStringAsFixed(2)} metros');

      const double maxDistance = 100.0;

      return distance <= maxDistance;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao validar localização: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrCodeValue = barcodes.first.rawValue;
    if (qrCodeValue == null || qrCodeValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final pontosVm = context.read<PontosViewmodel>();
      await pontosVm.loadCollectPoints();

      CollectPointModel? point;
      try {
        point = pontosVm.allPoints.firstWhere(
          (p) => p.qrCodeId == qrCodeValue,
        );
      } catch (e) {
        point = null;
      }

      if (point == null) {
        throw Exception('QR Code não corresponde a nenhum ponto de coleta');
      }

      bool isNearby = await _validateProximity(point);

      if (!mounted) return;

      if (!isNearby) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Row(
              children: [
                Icon(Icons.location_off, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Você está longe demais!',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Para registrar um descarte, você precisa estar próximo ao ponto de coleta identificado.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffF59E0B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xffF59E0B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Distância máxima: 100 metros',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Aproxime-se do ponto de coleta e tente novamente.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isProcessing = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Entendi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF59E0B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }

      Navigator.pop(context, {
        'pointId': point.id,
        'pointName': point.name,
        'qrCodeId': qrCodeValue,
      });
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Erro'),
            ],
          ),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isProcessing = false;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        backgroundColor: const Color(0xff00A63E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Posicione o QR Code do ponto de coleta\ndentro da área de leitura',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Certifique-se de estar próximo ao ponto\n(máximo 100 metros)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    
    final holePaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    final borderPaint = Paint()
      ..color = const Color(0xff00A63E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final cornerPaint = Paint()
      ..color = const Color(0xff00A63E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(16),
      ),
      holePaint,
    );
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(16),
      ),
      borderPaint,
    );

    final cornerLength = 30.0;
    
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    
    canvas.drawLine(Offset(left + scanAreaSize - cornerLength, top), 
                    Offset(left + scanAreaSize, top), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top), 
                    Offset(left + scanAreaSize, top + cornerLength), cornerPaint);
    
    canvas.drawLine(Offset(left, top + scanAreaSize - cornerLength), 
                    Offset(left, top + scanAreaSize), cornerPaint);
    canvas.drawLine(Offset(left, top + scanAreaSize), 
                    Offset(left + cornerLength, top + scanAreaSize), cornerPaint);
    
    canvas.drawLine(Offset(left + scanAreaSize - cornerLength, top + scanAreaSize), 
                    Offset(left + scanAreaSize, top + scanAreaSize), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top + scanAreaSize - cornerLength), 
                    Offset(left + scanAreaSize, top + scanAreaSize), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
