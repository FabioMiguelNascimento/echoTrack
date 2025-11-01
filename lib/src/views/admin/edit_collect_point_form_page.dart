import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/views/admin/home_admin_page.dart';
import 'package:provider/provider.dart';

// --- MUDANÇA 1: Converter para StatefulWidget ---
class EditCollectPointFormPage extends StatefulWidget {
  final CollectPointModel point;

  const EditCollectPointFormPage({super.key, required this.point});

  @override
  State<EditCollectPointFormPage> createState() =>
      _EditCollectPointFormPageState();
}

class _EditCollectPointFormPageState extends State<EditCollectPointFormPage> {
  // --- MUDANÇA 2: Criar Controllers locais ---
  // Estes controllers vão guardar o estado DO FORMULÁRIO DE EDIÇÃO
  late TextEditingController _nameController;
  late TextEditingController _postalController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late List<String> _selectedTrashTypes;

  // --- MUDANÇA 3: Pré-preencher os campos no initState ---
  @override
  void initState() {
    super.initState();
    // Pega o ponto de coleta recebido pelo widget
    final point = widget.point;

    // Inicializa os controllers com os valores existentes do ponto
    _nameController = TextEditingController(text: point.name);
    _postalController = TextEditingController(text: point.address.postal);
    _countryController = TextEditingController(text: point.address.country);
    _stateController = TextEditingController(text: point.address.state);
    _cityController = TextEditingController(text: point.address.city);
    _streetController = TextEditingController(text: point.address.street);
    _numberController = TextEditingController(text: point.address.number);

    // Cria uma CÓPIA local da lista de tipos de lixo
    _selectedTrashTypes = List<String>.from(point.trashTypes);
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
    // Nós ainda precisamos do ViewModel para:
    // 1. (vm.isLoading) -> Saber o estado de carregamento
    // 2. (vm.availableTrashTypes) -> Pegar a lista de lixos disponíveis
    // 3. (vmRead.updateCollectPoint) -> Disparar a ação de atualizar
    final vm = context.watch<PontosViewmodel>();
    final vmRead = context.read<PontosViewmodel>();

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
                              'Editar ponto de coleta',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 20),
                            // --- MUDANÇA 5: Usar os controllers LOCAIS ---
                            _buildTextField(
                              _nameController, // <-- MUDOU
                              'Nome do ponto',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _postalController, // <-- MUDOU
                              'CEP',
                              TextInputType.number,
                            ),
                            _buildTextField(
                              _countryController, // <-- MUDOU
                              'País',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _stateController, // <-- MUDOU
                              'Estado',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _cityController, // <-- MUDOU
                              'Cidade',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _streetController, // <-- MUDOU
                              'Rua',
                              TextInputType.text,
                            ),
                            _buildTextField(
                              _numberController, // <-- MUDOU
                              'Número',
                              TextInputType.number,
                            ),

                            SizedBox(height: 20),
                            Text('Tipos de lixo aceitos:'),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              // Usamos a lista de tipos do VM
                              itemCount: vm.availableTrashTypes.length,
                              itemBuilder: (context, index) {
                                final type = vm.availableTrashTypes[index];
                                return CheckboxListTile(
                                  title: Text(type),
                                  // --- MUDANÇA 6: Usar a lista LOCAL ---
                                  value: _selectedTrashTypes.contains(type),
                                  onChanged: (bool? value) {
                                    // --- MUDANÇA 7: Usar setState ---
                                    // Precisamos do setState para redesenhar
                                    // a tela quando o checkbox mudar
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
                                      // --- MUDANÇA 8: Validar com controllers locais ---
                                      if (_nameController.text.isEmpty ||
                                          _selectedTrashTypes.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Preencha nome e selecione ao menos um tipo de lixo',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // O ID NUNCA muda, pegamos do widget
                                      final String? pointId = widget.point.id;

                                      if (pointId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'ID do ponto não disponível para atualização.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // --- MUDANÇA 9: Criar modelo com dados locais ---
                                      final updated = CollectPointModel(
                                        id: pointId, // ID original
                                        name: _nameController.text.trim(),
                                        address: Address(
                                          street: _streetController.text.trim(),
                                          city: _cityController.text.trim(),
                                          number: _numberController.text.trim(),
                                          postal: _postalController.text.trim(),
                                          country: _countryController.text
                                              .trim(),
                                          state: _stateController.text.trim(),
                                          // Se você também edita coords,
                                          // precisa de controllers para elas
                                          cords: widget.point.address.cords,
                                        ),
                                        // Mantém o estado original
                                        isActive: widget.point.isActive,
                                        trashTypes: _selectedTrashTypes,
                                      );

                                      // O resto da lógica está PERFEITA
                                      final success = await vmRead
                                          .updateCollectPoint(pointId, updated);
                                      if (!mounted) return;
                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Ponto atualizado com sucesso',
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
