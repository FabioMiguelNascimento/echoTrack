import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/repositories/store_repository.dart';
import 'package:g1_g2/src/repositories/coupon_repository.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/models/store_model.dart';
import 'package:g1_g2/src/models/coupon_model.dart';

class SeedDataPage extends StatefulWidget {
  const SeedDataPage({super.key});

  @override
  State<SeedDataPage> createState() => _SeedDataPageState();
}

class _SeedDataPageState extends State<SeedDataPage> {
  bool _loading = false;

  Future<void> _seed() async {
    setState(() => _loading = true);
    try {
      final storeRepo = context.read<StoreRepository>();
      final couponRepo = context.read<CouponRepository>();

      // Gera um ID automático para a loja (não depende de usuário logado)
      final storesRef = FirebaseFirestore.instance.collection('stores');
      final newStoreDoc = storesRef.doc();
      final storeId = newStoreDoc.id;

      final store = StoreModel(
        uid: storeId,
        email: 'contato@exemplo.com',
        name: 'Farmácia São João',
        country: 'BR',
        state: 'RS',
        city: 'Taquara',
        address: 'Rua Exemplo, 123',
        cnpj: '12.345.676/0001-00',
      );

      // Cria a loja usando o repositório (irá gravar no doc com id gerado)
      await storeRepo.createStore(store);

      final coupon1 = CouponModel(
        id: '',
        storeId: storeId,
        title: '15% de desconto',
        description: '15% em produtos selecionados',
        discount: '15%',
        validUntil: DateTime.now().add(const Duration(days: 30)),
        minCollections: 3,
        quantityAvailable: 100,
      );

      final coupon2 = CouponModel(
        id: '',
        storeId: storeId,
        title: 'R\$5,00 de desconto',
        description: 'Desconto de R\$5 em compras acima de R\$20',
        discount: 'R\$5,00',
        validUntil: DateTime.now().add(const Duration(days: 60)),
        minCollections: 5,
        quantityAvailable: 50,
      );

      await couponRepo.createCoupon(coupon1);
      await couponRepo.createCoupon(coupon2);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados de exemplo criados com sucesso.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar dados: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const Scaffold(body: Center(child: Text('Seed disponível apenas em modo debug')));

    return Scaffold(
      appBar: AppBar(title: const Text('Seed de Dados (dev)'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Cria uma loja exemplo e dois cupons associados ao usuário logado.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _seed,
              child: _loading ? const CircularProgressIndicator() : const Text('Criar dados de exemplo'),
            ),
            const SizedBox(height: 12),
            const Text('Observação: os documentos são criados nas coleções `stores` e `coupons`.')
          ],
        ),
      ),
    );
  }
}
