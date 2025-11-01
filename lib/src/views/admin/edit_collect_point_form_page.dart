import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/views/admin/home_admin_page.dart';
import 'package:provider/provider.dart';

class EditCollectPointFormPage extends StatefulWidget {
  const EditCollectPointFormPage({super.key});

  @override
  State<EditCollectPointFormPage> createState() =>
      _EditCollectPointFormPageState();
}

class _EditCollectPointFormPageState extends State<EditCollectPointFormPage> {
  // Estes controllers vão guardar o estado DO FORMULÁRIO DE EDIÇÃO
  late TextEditingController _nameController;
  late TextEditingController _postalController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late List<String> _selectedTrashTypes;

  // Sinaliza se o initState falhou (ex: ponto nulo)
  bool _isLoadingError = false;

  @override
  void initState() {
    super.initState();
    // Pega o ponto de coleta recebido pelo widget
    final vm = context.read<PontosViewmodel>();

    // Pegando os dados do ponto que já está selecioando pelo vm
    final pointData = vm.getSelectedPointDataForEdit();

    if (pointData == null) {
      // Erro: O usuário não deveria estar aqui se nada foi selecionado
      _isLoadingError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: Nenhum ponto selecionado.')),
          );
          Navigator.pop(context);
        }
      });
      // Inicializa controllers vazios para evitar crash
      _nameController = TextEditingController();
      _postalController = TextEditingController();
      _countryController = TextEditingController();
      _stateController = TextEditingController();
      _cityController = TextEditingController();
      _streetController = TextEditingController();
      _numberController = TextEditingController();
      _selectedTrashTypes = [];
      return;
    }

    // --- MUDANÇA 3: Preencher controllers com dados do DTO ---
    _nameController = TextEditingController(text: pointData.name);
    _postalController = TextEditingController(text: pointData.postal);
    _countryController = TextEditingController(text: pointData.country);
    _stateController = TextEditingController(text: pointData.state);
    _cityController = TextEditingController(text: pointData.city);
    _streetController = TextEditingController(text: pointData.street);
    _numberController = TextEditingController(text: pointData.number);
    _selectedTrashTypes = List<String>.from(pointData.trashTypes);
  }

  // --- MUDANÇA 4: Limpar os controllers ---
  @override
  void dispose() {
    _nameController.dispose();
    _postalController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  // (O seu _buildTextField pode ficar aqui, sem mudanças)
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
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

    // Se o initState falhou, não mostra nada
    if (_isLoadingError) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        // ... (seu Container e Gradient)
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
                    // ... (seu Card e SingleChildScrollView)
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20), // Padding uniforme
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'Editar ponto de coleta',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                              _nameController,
                              'Nome do ponto',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _postalController,
                              'CEP',
                              TextInputType.number,
                            ),
                            _buildTextField(
                              _countryController,
                              'País',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _stateController,
                              'Estado',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _cityController,
                              'Cidade',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _streetController,
                              'Rua',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _numberController,
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
                                  value: _selectedTrashTypes.contains(type),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedTrashTypes.add(type);
                                      } else {
                                        _selectedTrashTypes.remove(type);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      final BuildContext localContext = context;

                                      if (_nameController.text.isEmpty ||
                                          _selectedTrashTypes.isEmpty) {
                                        ScaffoldMessenger.of(
                                          localContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Preencha nome e selecione ao menos um tipo de lixo',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // --- MUDANÇA 4: VIOLAÇÃO REMOVIDA ---
                                      // Não construímos o Model.
                                      // Apenas passamos os dados brutos para o VM.
                                      final success = await vmRead
                                          .updatePointFromForm(
                                            name: _nameController.text.trim(),
                                            postal: _postalController.text
                                                .trim(),
                                            country: _countryController.text
                                                .trim(),
                                            state: _stateController.text.trim(),
                                            city: _cityController.text.trim(),
                                            street: _streetController.text
                                                .trim(),
                                            number: _numberController.text
                                                .trim(),
                                            trashTypes: _selectedTrashTypes,
                                          );

                                      if (!localContext.mounted) return;

                                      if (success) {
                                        ScaffoldMessenger.of(
                                          localContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Ponto atualizado com sucesso',
                                            ),
                                          ),
                                        );
                                        // Retorna 'true' para a página de Detalhes
                                        Navigator.pop(localContext, true);
                                      } else {
                                        ScaffoldMessenger.of(
                                          localContext,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              vm.errorMessage ??
                                                  'Erro ao atualizar',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              child: vm.isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Salvar alterações'),
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
