// Libs
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g1_g2/src/repositories/discart_repository.dart';
import 'package:g1_g2/src/viewmodels/admin/pontos_viewmodel.dart';
import 'package:g1_g2/src/viewmodels/user/discart_viewmodel.dart';
import 'package:g1_g2/src/viewmodels/user/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Repositories
import 'package:g1_g2/src/repositories/auth_repository.dart';
import 'package:g1_g2/src/repositories/collect_point_repository.dart';
import 'package:g1_g2/src/repositories/user_repository.dart';
import 'package:g1_g2/src/repositories/store_repository.dart';
import 'package:g1_g2/src/repositories/coupon_repository.dart';

// Viewmodels
import 'package:g1_g2/src/viewmodels/auth/cadastro_viewmodel.dart';
import 'package:g1_g2/src/viewmodels/auth/login_viewmodel.dart';

// Pages
import 'package:g1_g2/src/views/auth/login_page.dart';

// Utils
import 'package:g1_g2/utils/home_selector.dart';

import 'firebase_options.dart'; // File: firebase_options.dart

// DEBUG FLAG: se true, abre sempre a tela de Login (útil para desenvolvimento)
const bool kForceLoginScreen = true;

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
        Provider<StoreRepository>(create: (_) => StoreRepository()),
        Provider<CouponRepository>(create: (_) => CouponRepository()),
        Provider<CollectPointRepository>(
          create: (_) => CollectPointRepository(),
        ),
        Provider<DiscartRepository>(create: (_) => DiscartRepository()),

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

        ChangeNotifierProvider<PontosViewmodel>(
          create: (context) => PontosViewmodel(
            context.read<CollectPointRepository>(),
            context.read<UserRepository>(),
          )..loadCollectPoints(),
        ),

        ChangeNotifierProvider<UserViewmodel>(
          create: (context) => UserViewmodel(
            context.read<UserRepository>(),
            context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => DiscartViewmodel(
            context.read<DiscartRepository>(),
            context.read<AuthRepository>(),
            context.read<UserRepository>(),
            context.read<CouponRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Seu App de Coleta',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        home: kForceLoginScreen ? const LoginPage() : const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoginPage();
    }

    return FutureBuilder<UserRole>(
      future: Provider.of<LoginViewModel>(
        context,
        listen: false,
      ).getUserRole(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          final role = snapshot.data!;
          switch (role) {
            case UserRole.admin:
              return HomeSelector(userType: 'admin');
            case UserRole.store:
              return HomeSelector(userType: 'store');
            default:
              return HomeSelector(userType: 'user');
          }
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
