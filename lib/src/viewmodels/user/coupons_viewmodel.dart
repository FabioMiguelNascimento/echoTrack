import 'package:flutter/foundation.dart';
import 'package:g1_g2/src/models/coupon_model.dart';
import 'package:g1_g2/src/models/user_coupon_model.dart';
import 'package:g1_g2/src/repositories/coupon_repository.dart';
import 'package:g1_g2/src/repositories/discart_repository.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';

class CouponsViewModel extends ChangeNotifier {
	final CouponRepository _couponRepository;
	final DiscartRepository _discartRepository;
	final AuthRepository _authRepository;

	CouponsViewModel(
		this._couponRepository,
		this._discartRepository,
		this._authRepository,
	);

	bool _loading = false;
	String? _error;
	List<CouponModel> _available = [];
	List<UserCouponModel> _claimed = [];
	int _totalCollections = 0;

	bool get isLoading => _loading;
	String? get errorMessage => _error;
	List<CouponModel> get availableCoupons => List.unmodifiable(_available);
	List<UserCouponModel> get claimedCoupons => List.unmodifiable(_claimed);
	int get userCollectionsCount => _totalCollections;

	Future<void> loadAvailableCoupons() async {
		_setLoading(true);
		_error = null;
		try {
			final user = _authRepository.currentUser;
			if (user == null) {
				_error = 'Usuário não autenticado';
				return;
			}

			// Busca descartes do usuário e filtra apenas status concluído
			final discartsAll = await _discartRepository.getDiscartsByUser(user.uid);
			final discartsConcluidos = discartsAll.where((d) {
				final s = d.status.toLowerCase();
				return s == 'concluido' || s == 'concluído';
			}).toList();
			_totalCollections = discartsConcluidos.length;

			// Antes de filtrar listagem, concedemos cupons elegíveis (isso atualiza quantidades). Use a quantidade total.
			await _couponRepository.grantEligibleCouponsForUser(
				userId: user.uid,
				userCollectionsCount: _totalCollections,
			);

			// Carrega cupons já resgatados pelo usuário
			_claimed = await _couponRepository.getUserCoupons(user.uid);

			// Carrega todos os cupons após possível concessão
			final all = await _couponRepository.getAllCoupons();

			final claimedIds = _claimed.map((c) => c.couponId).toSet();

			final now = DateTime.now();
			final filtered = <CouponModel>[];
			for (final c in all) {
				// já foi resgatado? então não entra em disponíveis
				if (claimedIds.contains(c.id)) continue;
				final notExpired = c.validUntil == null || !c.validUntil!.isBefore(now);
				if (!notExpired) continue;
				if (c.quantityAvailable <= 0) continue;
				if (_totalCollections < c.minCollections) continue;
				filtered.add(c);
			}

			_available = filtered;
		} catch (e) {
			_error = 'Erro ao carregar cupons: $e';
		} finally {
			_setLoading(false);
		}
	}

	void _setLoading(bool v) {
		_loading = v;
		notifyListeners();
	}
}
