import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_checkbox_tile.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
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

    _nameController = TextEditingController(text: pointData.name);
    _postalController = TextEditingController(text: pointData.postal);
    _countryController = TextEditingController(text: pointData.country);
    _stateController = TextEditingController(text: pointData.state);
    _cityController = TextEditingController(text: pointData.city);
    _streetController = TextEditingController(text: pointData.street);
    _numberController = TextEditingController(text: pointData.number);
    _selectedTrashTypes = List<String>.from(pointData.trashTypes);
  }

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

    // Se o initState falhou, não mostra nada
    if (_isLoadingError) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              Row(children: [SizedBox(width: 24), CustomVoltarTextButtom()]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Card(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Editar ponto de coleta',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('Nome:'),
                            _buildTextField(
                              _nameController,
                              'Nome do ponto',
                              TextInputType.text,
                            ),
                            SizedBox(height: 20),
                            Text('Endereço:'),
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
                            SizedBox(height: 5),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: vm.availableTrashTypes.length,
                              itemBuilder: (context, index) {
                                final type = vm.availableTrashTypes[index];

                                // Use uma cor padrão (cinza) caso o tipo não esteja no mapa
                                final Color itemColor =
                                    coresLixo[type] ?? Colors.grey;

                                return CustomCheckboxTile(
                                  title: type,
                                  color: itemColor,
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
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
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
                                onPressed: vm.isLoading
                                    ? null
                                    : () async {
                                        final BuildContext localContext =
                                            context;

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

                                        final success = await vmRead
                                            .updatePointFromForm(
                                              name: _nameController.text.trim(),
                                              postal: _postalController.text
                                                  .trim(),
                                              country: _countryController.text
                                                  .trim(),
                                              state: _stateController.text
                                                  .trim(),
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
