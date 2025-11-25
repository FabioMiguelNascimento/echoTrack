import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/views/auth/logout_confirmation.dart';
import 'package:g1_g2/src/models/coupon_model.dart';
import 'package:g1_g2/src/models/store_model.dart';
import 'package:g1_g2/src/viewmodels/store/store_viewmodel.dart';
import 'package:intl/intl.dart';

class StoreDashboardPage extends StatefulWidget {
  const StoreDashboardPage({super.key});

  @override
  State<StoreDashboardPage> createState() => _StoreDashboardPageState();
}

class _StoreDashboardPageState extends State<StoreDashboardPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _validUntilCtrl = TextEditingController();
  final _minCollectionsCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _discountCtrl.dispose();
    _validUntilCtrl.dispose();
    _minCollectionsCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _showEditStoreDialog() async {
    final viewModel = context.read<StoreViewModel>();
    final store = viewModel.store;

    if (store == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loja não encontrada')));
      return;
    }

    final nameCtrl = TextEditingController(text: store.name);
    final cnpjCtrl = TextEditingController(text: store.cnpj);
    final streetCtrl = TextEditingController(text: store.street ?? '');
    final numberCtrl = TextEditingController(text: store.number ?? '');
    final neighborhoodCtrl = TextEditingController(
      text: store.neighborhood ?? '',
    );
    final cityCtrl = TextEditingController(text: store.city);
    final stateCtrl = TextEditingController(text: store.state);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Loja'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cnpjCtrl,
                  decoration: const InputDecoration(labelText: 'CNPJ'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: streetCtrl,
                  decoration: const InputDecoration(labelText: 'Rua'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: numberCtrl,
                  decoration: const InputDecoration(labelText: 'Número'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: neighborhoodCtrl,
                  decoration: const InputDecoration(labelText: 'Bairro'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stateCtrl,
                  decoration: const InputDecoration(labelText: 'Estado (UF)'),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final updated = StoreModel(
        uid: store.uid,
        email: store.email,
        name: nameCtrl.text.trim(),
        country: store.country,
        state: stateCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        address:
            '${streetCtrl.text.trim()}, ${numberCtrl.text.trim()}, ${neighborhoodCtrl.text.trim()}, ${cityCtrl.text.trim()} - ${stateCtrl.text.trim()}',
        cnpj: cnpjCtrl.text.trim(),
        street: streetCtrl.text.trim(),
        number: numberCtrl.text.trim(),
        neighborhood: neighborhoodCtrl.text.trim(),
      );

      final success = await viewModel.updateStore(updated);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Loja atualizada')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Erro ao atualizar loja'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<StoreViewModel>();
      await viewModel.loadStore();
      await viewModel.loadCoupons();
    });
  }

  Future<void> _createCoupon() async {
    final viewModel = context.read<StoreViewModel>();
    final parsedDate = _parseDate(_validUntilCtrl.text.trim());
    if (parsedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data inválida. Use formato DD/MM/AAAA')),
      );
      return;
    }
    viewModel.setSelectedValidUntil(parsedDate);

    final success = await viewModel.createCoupon(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      discount: _discountCtrl.text.trim(),
      minCollections: int.tryParse(_minCollectionsCtrl.text) ?? 0,
      quantityAvailable: int.tryParse(_quantityCtrl.text) ?? 0,
    );

    if (!mounted) return;
    if (success) {
      _titleCtrl.clear();
      _descCtrl.clear();
      _discountCtrl.clear();
      _minCollectionsCtrl.clear();
      _quantityCtrl.clear();
      _validUntilCtrl.clear();
      viewModel.clearSelectedValidUntil();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cupom criado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Erro ao criar cupom'),
        ),
      );
    }
  }

  Future<void> _showEditDialog(CouponModel coupon) async {
    final titleCtrl = TextEditingController(text: coupon.title);
    final descCtrl = TextEditingController(text: coupon.description);
    final discountCtrl = TextEditingController(text: coupon.discount);
    final minCtrl = TextEditingController(
      text: coupon.minCollections.toString(),
    );
    final qtyCtrl = TextEditingController(
      text: coupon.quantityAvailable.toString(),
    );
    final validCtrl = TextEditingController(
      text: coupon.validUntil != null
          ? DateFormat('dd/MM/yyyy').format(coupon.validUntil!)
          : '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Editar Cupom'),
                  IconButton(
                    tooltip: 'Excluir',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final vm = context.read<StoreViewModel>();
                      final success = await vm.deleteCoupon(coupon.id);
                      if (!mounted) return;
                      if (success) {
                        Navigator.of(ctx).pop(false); // fecha o diálogo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cupom excluído')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              vm.errorMessage ?? 'Erro ao excluir cupom',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    TextField(
                      controller: discountCtrl,
                      decoration: const InputDecoration(labelText: 'Desconto'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: validCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Válido Até (DD/MM/AAAA)',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                        DateInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: minCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mínimo de Coletas',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: qtyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade Disponível',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final viewModel = context.read<StoreViewModel>();
      final parsed = _parseDate(validCtrl.text.trim());
      final updated = CouponModel(
        id: coupon.id,
        storeId: coupon.storeId,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        discount: discountCtrl.text.trim(),
        validUntil: parsed,
        minCollections: int.tryParse(minCtrl.text) ?? coupon.minCollections,
        quantityAvailable:
            int.tryParse(qtyCtrl.text) ?? coupon.quantityAvailable,
      );

      final success = await viewModel.updateCoupon(updated);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cupom atualizado')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Erro ao atualizar cupom'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoreViewModel>();
    final store = viewModel.store;
    final coupons = viewModel.coupons;
    final isLoading = viewModel.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Parceiro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const LogoutConfirmation(),
            ),
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Text(
                        store != null && store.name.isNotEmpty
                            ? store.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      store?.name ?? 'Nome da Loja',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _showEditStoreDialog();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Loja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _InfoCard(
                  color: Colors.purple,
                  icon: Icons.card_giftcard,
                  title: 'Cupons Ativos',
                  value: viewModel.activeCouponsCount.toString(),
                ),
                _InfoCard(
                  color: Colors.orange,
                  icon: Icons.receipt_long,
                  title: 'Cupons Usados',
                  value: '0',
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Text(
              'Novo Cupom',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Título do Cupom',
                        hintText: 'Ex: 15% de desconto',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _discountCtrl,
                      decoration: const InputDecoration(labelText: 'Desconto'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _validUntilCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Válido Até (DD/MM/AAAA)',
                        hintText: 'Digite a data',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                        DateInputFormatter(),
                      ],
                      onChanged: (value) {
                        final d = _parseDate(value);
                        if (d != null) {
                          viewModel.setSelectedValidUntil(d);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minCollectionsCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Mínimo de Coletas',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Quantidade Disponível',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _titleCtrl.clear();
                              _descCtrl.clear();
                              _discountCtrl.clear();
                              _minCollectionsCtrl.clear();
                              _quantityCtrl.clear();
                              _validUntilCtrl.clear();
                              viewModel.clearSelectedValidUntil();
                            },
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _createCoupon,
                            child: const Text('Criar Cupom'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : coupons.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: const [
                          Icon(
                            Icons.card_giftcard,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('Nenhum cupom cadastrado ainda.'),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: coupons.map((c) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: InkWell(
                          onTap: () => _showEditDialog(c),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green[50],
                                  child: Icon(
                                    Icons.local_offer,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.confirmation_number,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Qtd: ${c.quantityAvailable}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            c.validUntil != null
                                                ? 'Válido até: ${c.validUntil!.day.toString().padLeft(2, '0')}/${c.validUntil!.month.toString().padLeft(2, '0')}/${c.validUntil!.year}'
                                                : 'Sem validade',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.edit, color: Colors.grey[400]),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white70)),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Formatter para inserir automaticamente barras em DD/MM/AAAA
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll('/', '');
    if (digits.length > 8) digits = digits.substring(0, 8);
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      formatted += digits[i];
      if (i == 1 || i == 3) {
        if (i != digits.length - 1) formatted += '/';
      }
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

DateTime? _parseDate(String input) {
  if (input.length != 10) return null; // DD/MM/AAAA
  try {
    final parts = input.split('/');
    if (parts.length != 3) return null;
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final dt = DateTime(year, month, day);
    // Validação básica: se componentes batem (ex evita 32/13/2025 virar outra data)
    if (dt.day != day || dt.month != month || dt.year != year) return null;
    return dt;
  } catch (_) {
    return null;
  }
}
