import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_checkbox_tile.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:provider/provider.dart';

class AddCollectPointFormPage extends StatelessWidget {
  const AddCollectPointFormPage({super.key});

  // Widget de criação de campos de texto
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller, // Ver o que faz
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
  Widget build(BuildContext context) {
    final vm = context.watch<PontosViewmodel>();
    final vmRead = context.read<PontosViewmodel>();

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
              Row(children: [SizedBox(width: 24), CustomVoltarTextButtom()]),
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
                                'Cadastrar ponto de coleta',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('Nome:'),
                            _buildTextField(
                              vm.createNameController,
                              'Nome do ponto',
                              TextInputType.text,
                            ),
                            SizedBox(height: 20),
                            Text('Endereço:'),
                            _buildTextField(
                              vm.createPostalController,
                              'CEP',
                              TextInputType.number,
                            ),
                            _buildTextField(
                              vm.createCountryController,
                              'País',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.createStateController,
                              'Estado',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.createCityController,
                              'Cidade',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.createNeighborhoodController,
                              'Bairro',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.createStreetController,
                              'Rua',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.createNumberController,
                              'Número',
                              TextInputType.number,
                            ),

                            SizedBox(height: 20),
                            Text('Tipos de lixo aceitos:'),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: vm.availableTrashTypes.length,
                              itemBuilder: (context, index) {
                                final type = vm.availableTrashTypes[index];
                                final bool isSelected = vm
                                    .createSelectedTrashTypes
                                    .contains(type);

                                // Use uma cor padrão (cinza) caso o tipo não esteja no mapa
                                final Color itemColor =
                                    coresLixo[type] ?? Colors.grey;

                                return CustomCheckboxTile(
                                  title: type,
                                  color: itemColor,
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    vm.toggleCreateTrashType(type);
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
                                  Navigator.pop(context);
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
                                        bool sucesso = await vmRead.cadastrar();
                                        if (context.mounted) {
                                          if (sucesso) {
                                            vmRead.clearCreateForm();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Ponto cadastrado com sucesso!',
                                                ),
                                              ),
                                            );
                                            Navigator.pop(context, true);
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
