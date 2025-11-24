import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/repositories/coupon_repository.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/views/auth/logout_confirmation.dart';
import 'package:g1_g2/src/models/coupon_model.dart';
import 'package:g1_g2/src/repositories/store_repository.dart';
import 'package:g1_g2/src/models/store_model.dart';

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

  List<CouponModel> _coupons = [];
  bool _loading = false;
  String _storeId = '';
  StoreModel? _store;

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
    try {
      final auth = context.read<AuthRepository>();
      final user = auth.currentUser;
      final storeId = user?.uid;
      if (storeId == null || storeId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
        return;
      }

      final storeRepo = context.read<StoreRepository>();
      final store = await storeRepo.getStoreById(storeId);
      if (store == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loja não encontrada')));
        return;
      }

      final nameCtrl = TextEditingController(text: store.name);
      final addressCtrl = TextEditingController(text: store.address);
      final cnpjCtrl = TextEditingController(text: store.cnpj);

      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Editar Loja'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
                  TextField(controller: cnpjCtrl, decoration: const InputDecoration(labelText: 'CNPJ')),
                  TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Endereço')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
              ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Salvar')),
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
          state: store.state,
          city: store.city,
          address: addressCtrl.text.trim(),
          cnpj: cnpjCtrl.text.trim(),
        );

        await storeRepo.updateStore(storeId, updated);
        if (!mounted) return;
        setState(() => _store = updated);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loja atualizada')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar loja: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadStore();
      await _loadCoupons();
    });
  }

  Future<void> _loadStore() async {
    try {
      final auth = context.read<AuthRepository>();
      final user = auth.currentUser;
      final storeId = user?.uid;
      if (storeId == null || storeId.isEmpty) return;
      final storeRepo = context.read<StoreRepository>();
      final s = await storeRepo.getStoreById(storeId);
      if (!mounted) return;
      setState(() => _store = s);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _loadCoupons() async {
    setState(() => _loading = true);
    try {
      final couponRepo = context.read<CouponRepository>();
      if (_storeId.isEmpty) {
        final auth = context.read<AuthRepository>();
        final user = auth.currentUser;
        _storeId = user?.uid ?? '';
      }
      final list = await couponRepo.getCouponsByStore(_storeId);
      if (!mounted) return;
      setState(() => _coupons = list);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  int _activeCouponsCount() {
    final now = DateTime.now();
    return _coupons.where((c) {
      final valid = c.validUntil == null || c.validUntil!.isAfter(now);
      return valid && (c.quantityAvailable > 0);
    }).length;
  }

  Future<void> _createCoupon() async {
    try {
      final couponRepo = context.read<CouponRepository>();
      final auth = context.read<AuthRepository>();
      final user = auth.currentUser;
      final storeId = user?.uid;
      if (storeId == null || storeId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
        return;
      }
      final coupon = CouponModel(
        id: '',
        storeId: storeId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        discount: _discountCtrl.text.trim(),
        validUntil: DateTime.now().add(const Duration(days: 30)),
        minCollections: int.tryParse(_minCollectionsCtrl.text) ?? 0,
        quantityAvailable: int.tryParse(_quantityCtrl.text) ?? 0,
      );

      await couponRepo.createCoupon(coupon);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cupom criado')));
      _titleCtrl.clear();
      _descCtrl.clear();
      _discountCtrl.clear();
      _minCollectionsCtrl.clear();
      _quantityCtrl.clear();
      await _loadCoupons();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar cupom: $e')));
    }
  }

  Future<void> _showEditDialog(CouponModel coupon) async {
    final titleCtrl = TextEditingController(text: coupon.title);
    final descCtrl = TextEditingController(text: coupon.description);
    final discountCtrl = TextEditingController(text: coupon.discount);
    final minCtrl = TextEditingController(text: coupon.minCollections.toString());
    final qtyCtrl = TextEditingController(text: coupon.quantityAvailable.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Cupom'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
                TextField(controller: discountCtrl, decoration: const InputDecoration(labelText: 'Desconto')),
                TextField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Mínimo de Coletas'), keyboardType: TextInputType.number),
                TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantidade Disponível'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Salvar'),
            )
          ],
        );
      },
    );

    if (result == true) {
      try {
        final repo = context.read<CouponRepository>();
        final updated = CouponModel(
          id: coupon.id,
          storeId: coupon.storeId,
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          discount: discountCtrl.text.trim(),
          validUntil: coupon.validUntil,
          minCollections: int.tryParse(minCtrl.text) ?? coupon.minCollections,
          quantityAvailable: int.tryParse(qtyCtrl.text) ?? coupon.quantityAvailable,
        );
        await repo.updateCoupon(updated);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cupom atualizado')));
        await _loadCoupons();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar cupom: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Parceiro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => showDialog(context: context, builder: (_) => const LogoutConfirmation()),
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
                        _store != null && _store!.name.isNotEmpty ? _store!.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_store?.name ?? 'Nome da Loja', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async { await _showEditStoreDialog(); },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Loja'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                )
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
                _InfoCard(color: Colors.green, icon: Icons.inventory, title: 'Coletas', value: '0'),
                _InfoCard(color: Colors.purple, icon: Icons.card_giftcard, title: 'Cupons Ativos', value: _activeCouponsCount().toString()),
                _InfoCard(color: Colors.orange, icon: Icons.receipt_long, title: 'Cupons Usados', value: '0'),
              ],
            ),

            const SizedBox(height: 18),
            const Text('Novo Cupom', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Título do Cupom', hintText: 'Ex: 15% de desconto')),
                    const SizedBox(height: 8),
                    TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
                    const SizedBox(height: 8),
                    Row(children: [Expanded(child: TextFormField(controller: _discountCtrl, decoration: const InputDecoration(labelText: 'Desconto'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _validUntilCtrl, decoration: const InputDecoration(labelText: 'Válido Até')))]),
                    const SizedBox(height: 8),
                    Row(children: [Expanded(child: TextFormField(controller: _minCollectionsCtrl, decoration: const InputDecoration(labelText: 'Mínimo de Coletas'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _quantityCtrl, decoration: const InputDecoration(labelText: 'Quantidade Disponível')))]),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () { _titleCtrl.clear(); _descCtrl.clear(); _discountCtrl.clear(); _minCollectionsCtrl.clear(); _quantityCtrl.clear(); }, child: const Text('Cancelar'))),
                        const SizedBox(width: 8),
                        Expanded(child: ElevatedButton(onPressed: _createCoupon, child: const Text('Criar Cupom'))),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            // Cupons list (header removed as requested)
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _coupons.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: const [
                              Icon(Icons.card_giftcard, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('Nenhum cupom cadastrado ainda.'),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _coupons.map((c) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(c.title),
                              subtitle: Text(c.description),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) async {
                                  final repo = context.read<CouponRepository>();
                                  if (v == 'edit') {
                                    await _showEditDialog(c);
                                  } else if (v == 'decrement') {
                                    await repo.decrementCouponQuantity(c.id);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quantidade decrementada')));
                                    await _loadCoupons();
                                  } else if (v == 'delete') {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Confirmar exclusão'),
                                        content: const Text('Deseja excluir este cupom?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      await repo.deleteCoupon(c.id);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cupom excluído')));
                                      await _loadCoupons();
                                    }
                                  }
                                },
                                itemBuilder: (ctx) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                                  PopupMenuItem(value: 'decrement', child: Text('Marcar uso (-1)')),
                                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                                ],
                              ),
                              subtitleTextStyle: const TextStyle(fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              // show extra info below
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[50],
                                child: Icon(Icons.local_offer, color: Colors.green),
                              ),
                              // below the title, show metadata
                              dense: false,
                              // Use a Column in subtitle area to display extra metadata
                              tileColor: Colors.white,
                              // Build a small footer under the tile using subtitle
                              // We'll show quantity and validity
                              
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

  const _InfoCard({required this.color, required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.95), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.white.withOpacity(0.3), child: Icon(icon, color: Colors.white)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white70)),
                  Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

