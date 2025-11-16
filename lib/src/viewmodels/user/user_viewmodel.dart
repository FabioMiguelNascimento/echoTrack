import 'package:g1_g2/src/models/base/user_base_model.dart';
import 'package:g1_g2/src/models/normal_user_model.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/repositories/user_repository.dart';
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';

class UserViewmodel extends BaseViewModel {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  UserViewmodel(this._userRepository, this._authRepository);

  UsuarioBaseModel? _currentUser;
  UsuarioBaseModel? get currentUser => _currentUser;

  // Getters para view não precisar importar "UsuarioBaseModel" ou qualquer outro
  String get currentUserName => _currentUser?.name ?? '';
  String get currentUserEmail => _currentUser?.email ?? '';
  String get currentUserCountry =>
      (_currentUser as NormalUserModel?)?.country ?? '';
  String get currentUserState =>
      (_currentUser as NormalUserModel?)?.state ?? '';
  String get currentUserCity => (_currentUser as NormalUserModel?)?.city ?? '';
  String get currentUserCpf => (_currentUser as NormalUserModel?)?.cpf ?? '';

  // METODOS PRINCIPAIS
  // Solicita ao UserRepository dados do uid e atualiza o _currentUser
  Future<bool> loadCurrentUser() async {
    setLoading(true);
    try {
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) {
        setError('Usuário não está logado');
        return false;
      }
      final user = await _userRepository.getUserData(uid);
      if (user == null) {
        setError("Não encontrado");
        return false;
      } else {
        _currentUser = user as NormalUserModel?;
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String country,
    required String state,
    required String city,
    required String cpf,
  }) async {
    // verificar campos
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedCountry = country.trim();
    final trimmedState = state.trim();
    final trimmedCity = city.trim();
    final trimmedCpf = cpf.trim();

    if (trimmedName.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedCountry.isEmpty ||
        trimmedState.isEmpty ||
        trimmedCity.isEmpty ||
        trimmedCpf.isEmpty) {
      setError('Todos os campos são obrigatórios');
      return false;
    }

    // Validação simples para o email
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      setError('Email Inválido');
      return false;
    }

    // Verificar se existe usuário
    final currentUser = _currentUser;
    if (currentUser == null) {
      setError('Usuário não encontrado');
      return false;
    }

    // regra de usuário
    final currentUserRole = _currentUser!.role;
    if (currentUserRole != 'user') {
      setError('Regra de usuário inconsistente, contate o suporte');
      return false;
    }

    setLoading(true);
    notifyListeners();

    try {
      // Verificar se o email foi alterado e alterar o auth
      final emailChanged = trimmedEmail != currentUser.email;
      if (emailChanged) {
        try {
          await _authRepository.updateEmail(trimmedEmail);
        } catch (e) {
          // Tratar erros específicos do Auth
          if (e.toString().contains('requires-recent-login')) {
            setError('Por favor, faça login novamente para alterar o email');
          } else if (e.toString().contains('email-already-in-use')) {
            setError('Este email já está em uso');
          } else {
            setError('Erro ao atualizar email: ${e.toString()}');
          }
          setLoading(false);
          return false;
        }
      }

      // Construir novo objeto com os valores dos inputs
      final updatedUser = NormalUserModel(
        uid: currentUser.uid,
        email: trimmedEmail,
        name: trimmedName,
        country: trimmedCountry,
        state: trimmedState,
        city: trimmedCity,
        cpf: trimmedCpf,
      );

      await _userRepository.updateUserData(updatedUser.uid, updatedUser);

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Erro ao salvar: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      setError('Erro ao fazer ao sair da aplicação: ${e.toString()}');
    }
  }
}
