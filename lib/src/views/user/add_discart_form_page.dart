import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_checkbox_tile.dart';
import 'package:g1_g2/src/viewmodels/user/discart_viewmodel.dart';
import 'package:g1_g2/src/views/user/home_user_page.dart';
import 'package:g1_g2/src/views/user/qr_code_scanner_page.dart';
import 'package:provider/provider.dart';

class AddDiscartFormPage extends StatefulWidget {
  const AddDiscartFormPage({super.key});

  @override
  State<AddDiscartFormPage> createState() => _AddDiscartFormPageState();
}

class _AddDiscartFormPageState extends State<AddDiscartFormPage> {
  // Widget de criação de campos de texto
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 2, color: Color(0xff00A63E)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiscartViewmodel>();
    final vmRead = context.read<DiscartViewmodel>();

    final Map<String, Color> coresLixo = {
      'Papel': Colors.blue.shade600,
      'Plástico': Colors.red.shade600,
      'Metal': Colors.yellow.shade700,
      'Vidro': Colors.green.shade600,
      'Orgânico': Colors.orange.shade600,
      'Eletrônicos': Colors.purple.shade600,
      'Pilhas': Colors.deepOrange.shade600,
      'Baterias': Colors.pink.shade300,
    };

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Color(0x20000000)),
                    ),
                    shadowColor: Colors.transparent,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 30,
                          bottom: 30,
                          right: 20,
                          left: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Registrar Descarte',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            SizedBox(height: 20),
                            
                            if (vm.scannedCollectPointId != null)
                              Card(
                                color: Color(0xffF0FDF4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Color(0xff00A63E)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Color(0xff00A63E),
                                        size: 32,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ponto Identificado',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff00A63E),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              vm.scannedCollectPointName ?? '',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.qr_code_scanner, color: Color(0xff00A63E)),
                                        tooltip: 'Escanear outro ponto',
                                        onPressed: () async {
                                          final result = await Navigator.push<Map<String, dynamic>>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const QrCodeScannerPage(),
                                            ),
                                          );
                                          if (result != null && context.mounted) {
                                            vmRead.setScannedPoint(
                                              result['pointId'],
                                              result['pointName'],
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              // Botão para escanear QR Code
                              Card(
                                color: Color(0xffFEF3C7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Color(0xffF59E0B)),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    final result = await Navigator.push<Map<String, dynamic>>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const QrCodeScannerPage(),
                                      ),
                                    );
                                    if (result != null && context.mounted) {
                                      vmRead.setScannedPoint(
                                        result['pointId'],
                                        result['pointName'],
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.qr_code_scanner,
                                          color: Color(0xffF59E0B),
                                          size: 32,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Escanear QR Code',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xffF59E0B),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Toque para identificar o ponto de coleta',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xffD97706),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Color(0xffF59E0B),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 20),
                            
                            Text('Qunatidade Aproximada'),
                            _buildTextField(
                              vm.quantityController,
                              'Ex: 5kg, 2 pacotes, 1 sacola, etc',
                              TextInputType.text,
                            ),
                            SizedBox(height: 20),
                            Text('Obsevações'),
                            _buildTextField(
                              vm.observationController,
                              'Informações extras sobre o descarte',
                              TextInputType.text,
                            ),
                            SizedBox(height: 20),
                            Text('Tipos de lixo: '),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: vm.availableTrashTypes.length,
                              itemBuilder: (context, index) {
                                final type = vm.availableTrashTypes[index];
                                final bool isSelected = vm.selectedTrashType
                                    .contains(type);

                                // Use uma cor padrão (cinza) caso o tipo não esteja no mapa
                                final Color itemColor =
                                    coresLixo[type] ?? Colors.grey;

                                return CustomCheckboxTile(
                                  title: type,
                                  color: itemColor,
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    vm.selectTrashType(type);
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 20),

                            // --- BOTÃO CANCELAR ---
                            // Usamos o SizedBox para forçar a largura total
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Limpa o formulário incluindo o ponto escaneado
                                  vmRead.clearForm();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const HomeUserPage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  // Cor do texto
                                  foregroundColor: Colors.black87,
                                  // Cor de fundo
                                  backgroundColor: Colors.white,
                                  // Altura do botão
                                  minimumSize: const Size(0, 50),
                                  // Borda (cor e largura)
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  // Cantos arredondados (igual aos seus TextFields)
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ), // Espaçamento entre os botões
                            // --- BOTÃO CADASTRAR ---
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: vm.isLoading
                                    ? null // Deixa null para desabilitar
                                    : () async {
                                        bool sucesso = await vmRead
                                            .registerDiscart();
                                        if (context.mounted) {
                                          if (sucesso) {
                                            vmRead.clearForm();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Descarte registrado',
                                                ),
                                              ),
                                            );
                                            Navigator.of(
                                              context,
                                            ).pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const HomeUserPage(),
                                              ),
                                              (route) => false,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  vm.errorMessage ?? 'Erro',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  // Cor do fundo (verde da sua app)
                                  backgroundColor: const Color(0xff00A63E),
                                  // Cor do texto e ícone (branco)
                                  foregroundColor: Colors.white,
                                  // Cor do fundo quando desabilitado (loading)
                                  disabledBackgroundColor: const Color(
                                    0xff00A63E,
                                  ),
                                  // Cor do texto/ícone quando desabilitado
                                  disabledForegroundColor: Colors.white,
                                  // Altura do botão
                                  minimumSize: const Size(0, 50),
                                  // Cantos arredondados
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: vm.isLoading
                                    // Um CircularProgressIndicator pequeno e branco
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text(
                                        'Cadastrar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 90),
                          ],
                        ),
                      ),
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
}
