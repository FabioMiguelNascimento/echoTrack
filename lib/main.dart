import 'package:flutter/material.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/repositories/collect_point_repository.dart';
import 'package:g1_g2/src/repositories/user_repository.dart';
import 'package:g1_g2/src/viewmodels/auth/cadastro_viewmodel.dart';
import 'package:g1_g2/src/viewmodels/auth/login_viewmodel.dart';
import 'package:g1_g2/src/views/auth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- CAMADA 1: REPOSITÓRIOS (DEPENDÊNCIAS) ---
        // Eles são providos primeiro e não mudam.
        // Usamos Provider() padrão, pois eles não notificam a UI.
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<UserRepository>(create: (_) => UserRepository()),
        Provider<CollectPointRepository>(
          create: (_) => CollectPointRepository(),
        ),

        // --- CAMADA 2: VIEWMODELS (ESTADO) ---
        // Eles dependem da Camada 1 e notificam a UI.
        // Usamos ChangeNotifierProvider()
        ChangeNotifierProvider<LoginViewModel>(
          create: (contexto) => LoginViewModel(
            contexto.read<AuthRepository>(), // Injetando o AuthRepo
            contexto.read<UserRepository>(), // Injetando o UserRepo
          ),
        ),
        ChangeNotifierProvider<CadastroViewModel>(
          create: (contexto) => CadastroViewModel(
            contexto.read<AuthRepository>(), // Injetando o AuthRepo
            contexto.read<UserRepository>(), // Injetando o UserRepo
          ),
        ),

        // Adicione outros ViewModels aqui conforme necessário
        // Ex:
        // ChangeNotifierProvider<AddPontoColetaViewModel>(
        //   create: (contexto) => AddPontoColetaViewModel(
        //     contexto.read<PontoColetaRepository>(),
        //   ),
        // ),
      ],
      child: MaterialApp(
        title: 'Seu App de Coleta',
        theme: ThemeData(primarySwatch: Colors.green),
        // A tela inicial. O Provider saberá
        // encontrar o LoginViewModel para ela.
        home: LoginPage(),
      ),
    );
  }
}
