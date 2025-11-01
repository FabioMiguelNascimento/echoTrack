import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/viewmodels/admin/cadastro_ponto_viewmodel.dart';
import 'package:g1_g2/src/views/admin/home_admin_page.dart';
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
    final vm = context.watch<CadastroPontoViewmodel>();
    final vmRead = context.read<CadastroPontoViewmodel>();

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
              Row(
                children: [
                  SizedBox(width: 24),
                  CustomVoltarTextButtom(pageToBack: HomeAdminPage()),
                ],
              ),
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
                            Text(
                              'Cadastro do novo ponto',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                              vm.nameController,
                              'Nome do ponto',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.postalController,
                              'CEP',
                              TextInputType.number,
                            ),
                            _buildTextField(
                              vm.countryController,
                              'País',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.stateController,
                              'Estado',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.cityController,
                              'Cidade',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.neighborhoodController,
                              'Bairro',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.streetController,
                              'Rua',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              vm.numberController,
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
                                return CheckboxListTile(
                                  title: Text(type),
                                  value: vm.selectedTrashTypes.contains(type),
                                  onChanged: (bool? value) {
                                    vm.toggleTrashType(type);
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      bool sucesso = await vmRead.cadastrar();
                                      if (context.mounted) {
                                        if (sucesso) {
                                          vmRead.clear();
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
                              child: vm.isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Cadastrar'),
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
