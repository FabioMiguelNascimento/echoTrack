import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/repositories/store_repository.dart';
import 'package:g1_g2/src/models/store_model.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'store_dashboard_page.dart';

class RegisterStorePage extends StatefulWidget {
  const RegisterStorePage({super.key});

  @override
  State<RegisterStorePage> createState() => _RegisterStorePageState();
}

class _RegisterStorePageState extends State<RegisterStorePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cnpjCtrl.dispose();
    _addressCtrl.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
        return;
      }

      final store = StoreModel(
        uid: user.uid,
        email: user.email ?? '',
        name: _nameCtrl.text.trim(),
        country: 'BR',
        state: '',
        city: '',
        address: _addressCtrl.text.trim(),
        cnpj: _cnpjCtrl.text.trim(),
      );

      await storeRepo.createStore(store);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loja cadastrada com sucesso')));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StoreDashboardPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar loja: $e')));
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
              const Text('Cadastro da sua loja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('É necessário CNPJ para cadastrar.'),
              const SizedBox(height: 16),

              const Text('Informações Básicas', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do Ponto *', hintText: 'Farmácia São João'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cnpjCtrl,
                decoration: const InputDecoration(labelText: 'CNPJ *', hintText: '12.345.676/7674-56'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o CNPJ' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Endereço *', hintText: 'Rua, número, bairro, cidade'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o endereço' : null,
              ),

              const SizedBox(height: 12),
              const Text('Avatar da Loja'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameCtrl,
                    builder: (context, value, _) {
                      final text = (value.text.trim().isNotEmpty) ? value.text.trim() : '';
                      final letter = text.isNotEmpty ? text[0].toUpperCase() : '?';
                      return CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.green[50],
                        child: Text(letter, style: const TextStyle(fontSize: 36, color: Colors.green, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('A imagem será gerada automaticamente usando a primeira letra do nome do comércio.'),
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 12),
              const Text('Contato e Horários', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Telefone *', hintText: '5199912334455'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hoursCtrl,
                decoration: const InputDecoration(labelText: 'Horário de Funcionamento *', hintText: 'Seg Sex: 8h-18h | Sab 12h-18h'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o horário' : null,
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
                  )
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
