import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g1_g2/src/viewmodels/auth/login_viewmodel.dart';
import 'package:g1_g2/src/views/admin/welcome_admin_page.dart';
import 'package:g1_g2/src/views/auth/cadastro_page.dart';
import 'package:g1_g2/src/views/store/welcome_store_page.dart';
import 'package:g1_g2/src/views/user/welcome_user_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // 'watch' é ótimo para o 'build', pois reconstrói com 'isLoading'
    final loginVM = context.watch<LoginViewModel>();
    // 'read' é melhor para funções como 'onPressed'
    final loginVMRead = context.read<LoginViewModel>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0x20000000)),
                  ),
                  shadowColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      bottom: 30,
                      right: 20,
                      left: 20,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/logo2.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Right EcoPoints', style: TextStyle(fontSize: 24)),
                        Text(
                          'Facilite a coleta de lixo sustentável',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xff717182),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 30,
                          width: double.infinity,
                          child: Text('E-mail', style: TextStyle(fontSize: 17)),
                        ),
                        TextField(
                          controller: loginVM.emailController,
                          cursorColor: Color(0xff00A63E),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'seu@email.com',
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color(0xff00A63E),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(style: BorderStyle.none),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          height: 30,
                          width: double.infinity,
                          child: Text('Senha', style: TextStyle(fontSize: 17)),
                        ),
                        TextField(
                          controller: loginVM.passwordController,
                          obscureText: true,
                          cursorColor: Color(0xff00A63E),
                          decoration: InputDecoration(
                            hintText: 'Sua senha',
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color(0xff00A63E),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(style: BorderStyle.none),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: loginVM.isLoading
                              ? null
                              : () async {
                                  // Esconde o teclado
                                  FocusScope.of(context).unfocus();

                                  // Pega o ViewModel para chamar a função (context.read)
                                  final vm = context.read<LoginViewModel>();
                                  bool sucesso = await loginVMRead.login();

                                  if (!context.mounted) return;

                                  if (sucesso) {
                                    // 1. Pegamos o usuário que o ViewModel armazenou
                                    final usuario = vm.usuarioLogado;

                                    // 2. Criamos a rota (página) de destino
                                    Widget paginaDestino;

                                    if (usuario?.role == 'admin') {
                                      // Se o usuário for Admin...
                                      paginaDestino = WelcomeAdminPage();
                                    } else if (usuario?.role == 'store') {
                                      // Se for Loja...
                                      paginaDestino = WelcomeStorePage();
                                    } else if (usuario?.role == 'user') {
                                      // Se for Cliente...
                                      paginaDestino = WelcomeUserPage(uid: FirebaseAuth.instance.currentUser!.uid, userType: usuario!.role);
                                    } else {
                                      // Se for nulo ou desconhecido (não deve acontecer)
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Erro: Tipo de usuário desconhecido.",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return; // Para a execução
                                    }

                                    // 3. Navegamos para a página correta
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => paginaDestino,
                                      ),
                                    );
                                  } else {
                                    // Mostra o erro
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          loginVM.errorMessage ??
                                              "Erro desconhecido",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Color(0xff00A63E),
                            iconColor: Colors.white,
                            shadowColor: Colors.transparent,
                            minimumSize: Size(double.infinity, 50),
                          ),

                          child: loginVM.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Entrar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Não possui uma conta?"),
                    TextButton(
                      child: Text(
                        "Cadastre-se",
                        style: TextStyle(
                          color: Color(0xff00A63E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        // Limpa qualquer erro de login antes de ir
                        loginVMRead.setError(null);

                        // Navega para a tela de Cadastro
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CadastroPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
