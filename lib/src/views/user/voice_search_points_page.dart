import 'package:flutter/material.dart';
// Certifique-se de instalar speech_to_text: flutter pub add speech_to_text
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../models/collect_point_model.dart';
import '../../utils/map_controller.dart';
import '../../utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/viewmodels/user/user_viewmodel.dart';

class VoiceSearchPointsPage extends StatefulWidget {
  const VoiceSearchPointsPage({super.key});

  @override
  State<VoiceSearchPointsPage> createState() => _VoiceSearchPointsPageState();
}

class _VoiceSearchPointsPageState extends State<VoiceSearchPointsPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _searchText = '';
  List<CollectPointModel> _filteredPoints = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pontosVm = context.read<PontosViewmodel>();
      final userVm = context.read<UserViewmodel>();
      final city = userVm.currentUserCity.toLowerCase();
      setState(() {
        _filteredPoints = pontosVm.allPoints
            .where((p) => p.address.city.toLowerCase() == city)
            .toList();
      });
      // Optionally pre-request permission when opening the page
      PermissionHelper.requestMicrophonePermission(context);
    });
  }

  void _startListening() async {
    final status = await PermissionHelper.requestMicrophonePermission(context);
    if (status != PermissionStatus.granted) return;
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchText = result.recognizedWords;
            final pontosVm = context.read<PontosViewmodel>();
            final userVm = context.read<UserViewmodel>();
            final city = userVm.currentUserCity.toLowerCase();
            final candidates = pontosVm.allPoints
                .where((p) => p.address.city.toLowerCase() == city)
                .toList();
            final query = _searchText.toLowerCase();
            _filteredPoints = candidates.where((p) {
              return p.name.toLowerCase().contains(query) ||
                  p.address.street.toLowerCase().contains(query) ||
                  p.address.neighborhood.toLowerCase().contains(query);
            }).toList();
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar pontos por voz')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Substitua por seu botão customizado de microfone se necessário
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 40,
              color: Colors.green,
            ),
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            _isListening
                ? 'Fale o nome ou endereço do ponto...'
                : 'Toque no microfone para buscar',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (_searchText.isNotEmpty)
            Text(
              'Você disse: $_searchText',
              style: const TextStyle(fontSize: 18),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPoints.length,
              itemBuilder: (context, index) {
                final ponto = _filteredPoints[index];
                return ListTile(
                  title: Text(ponto.name),
                  subtitle: Text(
                    '${ponto.address.street}, ${ponto.address.number}',
                  ),
                  trailing: Icon(Icons.location_on, color: Colors.green),
                  onTap: () {
                    MapController.followRouteToPoint(ponto);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
