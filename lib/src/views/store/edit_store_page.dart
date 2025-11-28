import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/models/store_model.dart';
import 'package:g1_g2/src/repositories/store_repository.dart';
import 'package:g1_g2/src/viewmodels/store/store_viewmodel.dart';
import 'package:g1_g2/src/utils/permission_helper.dart';
import 'welcome_store_page.dart';

class EditStorePage extends StatefulWidget {
  final StoreModel store;
  const EditStorePage({super.key, required this.store});

  @override
  State<EditStorePage> createState() => _EditStorePageState();
}

class _EditStorePageState extends State<EditStorePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _cnpjCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _numberCtrl;
  late TextEditingController _neighborhoodCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  XFile? _storeImage;

  @override
  void initState() {
    super.initState();
    final s = widget.store;
    _nameCtrl = TextEditingController(text: s.name);
    _cnpjCtrl = TextEditingController(text: s.cnpj);
    _streetCtrl = TextEditingController(text: s.street ?? '');
    _numberCtrl = TextEditingController(text: s.number ?? '');
    _neighborhoodCtrl = TextEditingController(text: s.neighborhood ?? '');
    _cityCtrl = TextEditingController(text: s.city);
    _stateCtrl = TextEditingController(text: s.state);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cnpjCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final viewModel = context.read<StoreViewModel>();
    String? uploadedImageUrl = widget.store.imageUrl;
    if (_storeImage != null) {
      try {
        final repo = context.read<StoreRepository>();
        uploadedImageUrl = await repo.uploadStoreImage(
          widget.store.uid,
          _storeImage!,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha ao enviar imagem: $e')));
        return;
      }
    }

    final updated = StoreModel(
      uid: widget.store.uid,
      email: widget.store.email,
      name: _nameCtrl.text.trim(),
      country: widget.store.country,
      state: _stateCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      address:
          '${_streetCtrl.text.trim()}, ${_numberCtrl.text.trim()}, ${_neighborhoodCtrl.text.trim()}, ${_cityCtrl.text.trim()} - ${_stateCtrl.text.trim()}',
      cnpj: _cnpjCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      number: _numberCtrl.text.trim(),
      neighborhood: _neighborhoodCtrl.text.trim(),
      imageUrl: uploadedImageUrl,
    );

    final success = await viewModel.updateStore(updated);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loja atualizada')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Erro ao atualizar loja'),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir loja'),
        content: const Text(
          'Deseja realmente excluir sua loja? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final viewModel = context.read<StoreViewModel>();
      final success = await viewModel.deleteStore();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Loja excluída')));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeStorePage()),
          (r) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Erro ao excluir loja'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Loja'),
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
              // Top image selector (preview uses existing imageUrl if present)
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
                          setState(() => _storeImage = file);
                          // Optionally upload immediately and set imageUrl on store - omitted here
                        }
                      },
                      child: CircleAvatar(
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
                            : (widget.store.imageUrl != null &&
                                  widget.store.imageUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.network(
                                  widget.store.imageUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                widget.store.name.isNotEmpty
                                    ? widget.store.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Adicione uma imagem para a loja (opcional)'),
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
                decoration: const InputDecoration(labelText: 'Nome do Ponto *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cnpjCtrl,
                decoration: const InputDecoration(labelText: 'CNPJ *'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o CNPJ' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _streetCtrl,
                decoration: const InputDecoration(labelText: 'Rua *'),
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
                      decoration: const InputDecoration(labelText: 'Número *'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe o número' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _neighborhoodCtrl,
                      decoration: const InputDecoration(labelText: 'Bairro *'),
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
                      decoration: const InputDecoration(labelText: 'Cidade *'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a cidade' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(labelText: 'UF *'),
                      maxLength: 2,
                      validator: (v) => (v == null || v.isEmpty) ? 'UF' : null,
                    ),
                  ),
                ],
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
                      onPressed: _save,
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete),
                label: const Text('Excluir Loja'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
