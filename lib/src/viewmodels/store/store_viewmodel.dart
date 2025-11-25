import 'package:g1_g2/src/models/store_model.dart';
import 'package:g1_g2/src/models/coupon_model.dart';
import 'package:g1_g2/src/repositories/store_repository.dart';
import 'package:g1_g2/src/repositories/coupon_repository.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';

class StoreViewModel extends BaseViewModel {
  final StoreRepository _storeRepository;
  final CouponRepository _couponRepository;
  final AuthRepository _authRepository;

  StoreViewModel(
    this._storeRepository,
    this._couponRepository,
    this._authRepository,
  );

  // Estado
  StoreModel? _store;
  List<CouponModel> _coupons = [];
  DateTime? _selectedValidUntil;

  // Getters
  StoreModel? get store => _store;
  List<CouponModel> get coupons => List.unmodifiable(_coupons);
  DateTime? get selectedValidUntil => _selectedValidUntil;

  int get activeCouponsCount {
    final now = DateTime.now();
    return _coupons.where((c) {
      final valid = c.validUntil == null || c.validUntil!.isAfter(now);
      return valid && (c.quantityAvailable > 0);
    }).length;
  }

  // Métodos
  void setSelectedValidUntil(DateTime? date) {
    _selectedValidUntil = date;
    notifyListeners();
  }

  void clearSelectedValidUntil() {
    _selectedValidUntil = null;
    notifyListeners();
  }

  Future<void> loadStore() async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) return;
      
      final storeData = await _storeRepository.getStoreById(user.uid);
      _store = storeData;
      notifyListeners();
    } catch (e) {
      setError('Erro ao carregar loja: $e');
    }
  }

  Future<void> loadCoupons() async {
    setLoading(true);
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        setError('Usuário não autenticado');
        return;
      }

      final couponsList = await _couponRepository.getCouponsByStore(user.uid);
      _coupons = couponsList;
      notifyListeners();
    } catch (e) {
      setError('Erro ao carregar cupons: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createCoupon({
    required String title,
    required String description,
    required String discount,
    required int minCollections,
    required int quantityAvailable,
  }) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        setError('Usuário não autenticado');
        return false;
      }

      final coupon = CouponModel(
        id: '',
        storeId: user.uid,
        title: title,
        description: description,
        discount: discount,
        validUntil: _selectedValidUntil ?? DateTime.now().add(const Duration(days: 30)),
        minCollections: minCollections,
        quantityAvailable: quantityAvailable,
      );

      await _couponRepository.createCoupon(coupon);
      clearSelectedValidUntil();
      await loadCoupons();
      return true;
    } catch (e) {
      setError('Erro ao criar cupom: $e');
      return false;
    }
  }

  Future<bool> updateCoupon(CouponModel coupon) async {
    try {
      await _couponRepository.updateCoupon(coupon);
      await loadCoupons();
      return true;
    } catch (e) {
      setError('Erro ao atualizar cupom: $e');
      return false;
    }
  }

  Future<bool> deleteCoupon(String couponId) async {
    try {
      await _couponRepository.deleteCoupon(couponId);
      await loadCoupons();
      return true;
    } catch (e) {
      setError('Erro ao excluir cupom: $e');
      return false;
    }
  }

  Future<bool> updateStore(StoreModel updatedStore) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        setError('Usuário não autenticado');
        return false;
      }

      await _storeRepository.updateStore(user.uid, updatedStore);
      _store = updatedStore;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Erro ao atualizar loja: $e');
      return false;
    }
  }
}
