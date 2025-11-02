import 'package:flutter/material.dart';
import 'package:g1_g2/src/models/admin_model.dart';
import 'package:g1_g2/src/models/normal_user_model.dart';
import 'package:g1_g2/src/models/store_model.dart';
import 'package:g1_g2/src/models/base/user_base_model.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g1_g2/src/viewmodels/base_viewmodel.dart';

// Enum para clareza
enum TipoUsuario { cliente, loja, admin }

class CadastroViewModel extends BaseViewModel {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  // Injetando as dependencias via construtor
  CadastroViewModel(this._authRepo, this._userRepo);

  //--- Estado de Seleção de Tipo ---
  TipoUsuario _tipoSelecionado = TipoUsuario.cliente;
  TipoUsuario get tipoSelecionado => _tipoSelecionado;

  void setTipoUsuario(TipoUsuario tipo) {
    _tipoSelecionado = tipo;
    notifyListeners();
  }

  //--- Controladores Comuns ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  //--- Controladores Específicos ---
  // (A View só deve mostrar os campos relevantes)
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
  final TextEditingController enderecoLojaController = TextEditingController();

  /// Tenta cadastrar um novo usuário. Retorna [true] se for sucesso.
  Future<bool> cadastrar() async {
    setLoading(true);
    UserCredential? credential; // Para guardar a credencial de auth

    try {
      // Validação (faça uma mais robusta)
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          nomeController.text.isEmpty) {
        throw Exception("Preencha os campos obrigatórios.");
      }

      // Passo 1: Criar usuário no Firebase Auth
      credential = await _authRepo.createUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (credential.user == null) throw Exception("Erro ao criar usuário.");

      final uid = credential.user!.uid;

      // Passo 2: Criar o Modelo de dados correto
      UsuarioBaseModel novoUsuario;

      switch (_tipoSelecionado) {
        case TipoUsuario.cliente:
          novoUsuario = NormalUserModel(
            uid: uid,
            email: emailController.text.trim(),
            name: nomeController.text.trim(),
            country: countryController.text.trim(),
            state: stateController.text.trim(),
            city: cityController.text.trim(),
            cpf: cpfController.text.trim(),
          );
          break;
        case TipoUsuario.loja:
          novoUsuario = StoreModel(
            uid: uid,
            email: emailController.text.trim(),
            name: nomeController.text.trim(), // Nome da Loja
            city: cityController.text.trim(),
            country: countryController.text.trim(),
            state: stateController.text.trim(),
            cnpj: cnpjController.text.trim(),
            address: enderecoLojaController.text.trim(),
          );
          break;
        case TipoUsuario.admin:
          novoUsuario = AdminModel(
            uid: uid,
            email: emailController.text.trim(),
            name: nomeController.text.trim(),
            country: countryController.text.trim(),
            state: stateController.text.trim(),
            city: cityController.text.trim(),
          );
          break;
      }

      // Passo 3: Salvar o modelo no Firestore
      await _userRepo.createUserData(novoUsuario);

      // Sucesso!
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      // Trata erros de cadastro (ex: email já em uso)
      // Garantir que o loading sempre seja desligado antes de retornar
      setLoading(false);
      if (e.code == 'email-already-in-use') {
        setError("Este e-mail já está em uso.");
      } else if (e.code == 'weak-password') {
        setError("A senha é muito fraca.");
      } else {
        setError("Erro de autenticação. Tente novamente.");
      }
      return false;
    } catch (e) {
      // **LÓGICA DE ROLLBACK (MUITO IMPORTANTE!)**
      // Se o Passo 2 ou 3 falhar (ex: erro no Firestore), mas o Passo 1
      // funcionou, temos que deletar o usuário do Auth.
      if (credential?.user != null) {
        try {
          await credential!.user!.delete(); // Deleta o usuário do Auth
        } catch (deleteErr) {
          // Se a deleção falhar, registra no log e segue para setError abaixo.
          // Evitamos estourar a app aqui.
          // Você pode enviar esse erro para Sentry/Crashlytics se usar.
        }
      }

      // Garantir que o loading seja desligado
      setLoading(false);
      setError("Erro ao salvar dados: ${e.toString()}");
      return false;
    }
  }

  @override
  void dispose() {
    // Limpar todos os controllers
    emailController.dispose();
    passwordController.dispose();
    nomeController.dispose();
    countryController.dispose();
    stateController.dispose();
    cpfController.dispose();
    cnpjController.dispose();
    enderecoLojaController.dispose();
    cityController.dispose();
    super.dispose();
  }
}
