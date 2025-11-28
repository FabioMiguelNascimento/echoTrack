import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/repositories/store_repository.dart';
import 'package:g1_g2/src/models/store_model.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'store_dashboard_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:g1_g2/src/utils/permission_helper.dart';

class RegisterStorePage extends StatefulWidget {
  const RegisterStorePage({super.key});

  @override
  State<RegisterStorePage> createState() => _RegisterStorePageState();
}

class _RegisterStorePageState extends State<RegisterStorePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  XFile? _storeImage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cnpjCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _phoneCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    _doSubmit();
  }

  Future<void> _doSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {});
    try {
      final auth = context.read<AuthRepository>();
      final storeRepo = context.read<StoreRepository>();

      final user = auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado')),
        );
        return;
      }

      // If user selected an image, upload it first and get the URL
      String? uploadedImageUrl;
      if (_storeImage != null) {
        try {
          uploadedImageUrl = await storeRepo.uploadStoreImage(
            user.uid,
            _storeImage!,
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Falha ao enviar imagem: $e')));
        }
      }

      final storeToSave = StoreModel(
        uid: user.uid,
        email: user.email ?? '',
        name: _nameCtrl.text.trim(),
        country: 'BR',
        state: _stateCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        address:
            '${_streetCtrl.text.trim()}, ${_numberCtrl.text.trim()}, ${_neighborhoodCtrl.text.trim()}, ${_cityCtrl.text.trim()} - ${_stateCtrl.text.trim()}',
        cnpj: _cnpjCtrl.text.trim(),
        imageUrl: uploadedImageUrl,
        street: _streetCtrl.text.trim(),
        number: _numberCtrl.text.trim(),
        neighborhood: _neighborhoodCtrl.text.trim(),
      );

      await storeRepo.createStore(storeToSave);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loja cadastrada com sucesso')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StoreDashboardPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao cadastrar loja: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro da Loja'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Cadastro da sua loja',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('É necessário CNPJ para cadastrar.'),
              const SizedBox(height: 16),

              // Top image selector / avatar
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final status =
                            await GalleryPermission.requestGalleryPermission(
                              context,
                            );
                        if (!status.isGranted) return;
                        final XFile? file = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                          maxWidth: 1200,
                        );
                        if (file != null) {
                          setState(() {
                            _storeImage = file;
                          });
                        }
                      },
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _nameCtrl,
                        builder: (context, value, _) {
                          final text = (value.text.trim().isNotEmpty)
                              ? value.text.trim()
                              : '';
                          final letter = text.isNotEmpty
                              ? text[0].toUpperCase()
                              : '?';
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.green[50],
                            child: _storeImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.file(
                                      File(_storeImage!.path),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Adicione uma imagem para a loja (opcional)'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final status =
                                await GalleryPermission.requestGalleryPermission(
                                  context,
                                );
                            if (!status.isGranted) return;
                            final XFile? file = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxWidth: 1200,
                            );
                            if (file != null) {
                              setState(() {
                                _storeImage = file;
                              });
                            }
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Selecionar imagem'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_storeImage != null)
                          TextButton(
                            onPressed: () => setState(() => _storeImage = null),
                            child: const Text('Remover'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const Text(
                'Informações Básicas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do Ponto *',
                  hintText: 'Farmácia São João',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cnpjCtrl,
                decoration: const InputDecoration(
                  labelText: 'CNPJ *',
                  hintText: '12.345.676/7674-56',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o CNPJ' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _streetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Rua *',
                  hintText: 'Rua das Flores',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a rua' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _numberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Número *',
                        hintText: '123',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe o número' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _neighborhoodCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bairro *',
                        hintText: 'Centro',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe o bairro' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cidade *',
                        hintText: 'Taquara',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a cidade' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'UF *',
                        hintText: 'RS',
                      ),
                      maxLength: 2,
                      validator: (v) => (v == null || v.isEmpty) ? 'UF' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Text(
                'Contato e Horários',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Telefone *',
                  hintText: '5199912334455',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hoursCtrl,
                decoration: const InputDecoration(
                  labelText: 'Horário de Funcionamento *',
                  hintText: 'Seg Sex: 8h-18h | Sab 12h-18h',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o horário' : null,
              ),

              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Cadastrar Comércio'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
