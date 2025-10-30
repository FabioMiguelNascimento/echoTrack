import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/base/user_base_model.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/repositories/user_repository.dart';
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para tratar erros

class LoginViewModel extends BaseViewModel {
  // 1. Dependências (Repos)
  // (Para um projeto real, injete-os via get_it ou provider)
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  
  // Construtor que recebe as dependências
  LoginViewModel(this._authRepo, this._userRepo);


  // 2. Controladores (Dados da UI)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 3. Estado (Resultado)
  UsuarioBaseModel? usuarioLogado;

  // 4. Método de Orquestração
  /// Tenta logar o usuário. Retorna [true] se for sucesso.
  Future<bool> login() async {
    // Validação básica
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setError("Por favor, preencha e-mail e senha.");
      return false;
    }
    
    setLoading(true);

    try {
      // Passo 1: Autenticar no Firebase Auth
      final credential = await _authRepo.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (credential.user == null) throw Exception("Usuário não encontrado.");
      
      final uid = credential.user!.uid;

      // Passo 2: Buscar dados do usuário no Firestore
      final usuario = await _userRepo.getUserData(uid);

      if (usuario == null) {
        // Raro, mas pode acontecer: usuário existe no Auth mas não no Firestore
        // Desloga o usuário para evitar estado inconsistente
        await _authRepo.signOut();
        throw Exception("Dados do usuário não encontrados. Contate o suporte.");
      }

      // Sucesso!
      usuarioLogado = usuario; // Salva o usuário no ViewModel
      setLoading(false);
      return true;

    } on FirebaseAuthException catch (e) {
      // Trata erros de login (ex: senha errada)
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setError("E-mail ou senha inválidos.");
      } else {
        setError("Ocorreu um erro desconhecido. Tente novamente.");
      }
      return false;
    } catch (e) {
      // Trata outros erros (ex: falha ao buscar no Firestore)
      setError(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    // Sempre limpe os controllers
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}