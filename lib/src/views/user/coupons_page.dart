import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/models/coupon_model.dart';
import 'package:g1_g2/src/models/store_model.dart';
import 'package:g1_g2/src/repositories/store_repository.dart';
import 'package:g1_g2/src/repositories/coupon_repository.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/src/viewmodels/user/coupons_viewmodel.dart';
import 'package:intl/intl.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  // Pequeno widget helper para chips de detalhe
  Widget _detailChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.green),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _showCouponDetails({
    required String couponId,
    CouponModel? existing,
  }) async {
    final couponRepo = context.read<CouponRepository>();
    final storeRepo = context.read<StoreRepository>();
    CouponModel? coupon = existing;
    if (coupon == null || coupon.storeId.isEmpty) {
      coupon = await couponRepo.getCouponById(couponId);
    }
    if (coupon == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cupom não encontrado')));
      return;
    }
    StoreModel? store;
    try {
      store = await storeRepo.getStoreById(coupon.storeId);
    } catch (_) {}

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final validadeStr = coupon!.validUntil != null
            ? DateFormat('dd/MM/yyyy').format(coupon.validUntil!)
            : 'Sem validade';
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        coupon.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(coupon.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _detailChip(
                      icon: Icons.percent,
                      label: 'Desconto',
                      value: coupon.discount.isEmpty ? '-' : coupon.discount,
                    ),
                    _detailChip(
                      icon: Icons.check_circle,
                      label: 'Mín. Coletas',
                      value: '${coupon.minCollections}',
                    ),
                    _detailChip(
                      icon: Icons.calendar_today,
                      label: 'Validade',
                      value: validadeStr,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Como Resgatar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (store != null) ...[
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.address.isNotEmpty
                        ? store.address
                        : 'Endereço não disponível',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  const Text(
                    'Informações da loja não encontradas.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text(
                  'Apresente este cupom ao atendente no ato da compra/coleta para validar o benefício.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                        label: const Text('Fechar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponsViewModel>().loadAvailableCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CouponsViewModel>();
    return CustomInitialLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cupons',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => vm.loadAvailableCoupons(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar'),
                ),
              ],
            ),
            Text(
              'Coletas concluídas: ${vm.userCollectionsCount}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            if (vm.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (vm.errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Próximos Cupons',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<CouponModel>>(
                      future: context.read<CouponRepository>().getAllCoupons(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.card_giftcard,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Nenhum cupom disponível.'),
                                ],
                              ),
                            ),
                          );
                        }

                        final allCoupons = snapshot.data!;
                        final claimedIds = vm.claimedCoupons
                            .map((c) => c.couponId)
                            .toSet();
                        final now = DateTime.now();

                        // Filtra apenas cupons bloqueados (ainda não atingiu o mínimo)
                        final blockedCoupons = allCoupons.where((c) {
                          final notExpired =
                              c.validUntil == null ||
                              !c.validUntil!.isBefore(now);
                          final jaResgatado = claimedIds.contains(c.id);
                          final bloqueado =
                              vm.userCollectionsCount < c.minCollections;
                          return notExpired &&
                              c.quantityAvailable > 0 &&
                              !jaResgatado &&
                              bloqueado;
                        }).toList();

                        if (blockedCoupons.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.celebration,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Parabéns! Você já liberou todos os cupons disponíveis.',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: blockedCoupons.map((c) {
                            // Ensure numeric safety: use a double denominator and clamp progress as double
                            final denom = c.minCollections
                                .clamp(1, c.minCollections)
                                .toDouble();
                            final progresso = vm.userCollectionsCount / denom;
                            final progressoClamped = progresso
                                .clamp(0.0, 1.0)
                                .toDouble();
                            // faltam no máximo o número de coletas necessárias
                            final falta =
                                (c.minCollections - vm.userCollectionsCount)
                                    .clamp(0, c.minCollections)
                                    .toInt();

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange[100],
                                  child: Icon(Icons.lock, color: Colors.orange),
                                ),
                                title: Text(
                                  c.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.description),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Faltam $falta coleta${falta != 1 ? 's' : ''}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: LinearProgressIndicator(
                                                  value: progressoClamped,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  valueColor:
                                                      const AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.orange),
                                                  minHeight: 8,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${vm.userCollectionsCount} / ${c.minCollections} coletas',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Seus Cupons',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (vm.claimedCoupons.isEmpty)
                      const Text(
                        'Nenhum cupom resgatado ainda.',
                        style: TextStyle(fontSize: 12),
                      )
                    else
                      Column(
                        children: vm.claimedCoupons.map((uc) {
                          final coupon = vm.availableCoupons.firstWhere(
                            (c) => c.id == uc.couponId,
                            orElse: () => CouponModel(
                              id: uc.couponId,
                              storeId: '',
                              title: 'Cupom',
                              description: '',
                              discount: '',
                              minCollections: 0,
                              quantityAvailable: 0,
                              validUntil: null,
                            ),
                          );
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.card_giftcard),
                              title: Text(coupon.title),
                              subtitle: Text(coupon.description),
                              trailing: uc.used
                                  ? const Chip(
                                      label: Text('Usado'),
                                      backgroundColor: Colors.grey,
                                    )
                                  : const Chip(
                                      label: Text('Disponível'),
                                      backgroundColor: Colors.greenAccent,
                                    ),
                              onTap: () => _showCouponDetails(
                                couponId: uc.couponId,
                                existing: coupon,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
