import 'package:cat_tinder/presentation/pages/auth_page.dart';
import 'package:cat_tinder/presentation/pages/onboarding_page.dart';
import 'package:cat_tinder/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/datasources/cat_api.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cat_repository.dart';
import 'domain/usecases/auth_usecases.dart';
import 'presentation/providers/breeds_provider.dart';
import 'presentation/providers/cat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  final onboardingCompleted = sharedPreferences.getBool('onboarding_completed') ?? false;

  runApp(MyApp(
    onboardingCompleted: onboardingCompleted,
    sharedPreferences: sharedPreferences,
    secureStorage: secureStorage,
  ));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  const MyApp({
    super.key,
    required this.onboardingCompleted,
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<http.Client>(create: (_) => http.Client()),
        Provider<SharedPreferences>.value(value: sharedPreferences),
        Provider<FlutterSecureStorage>.value(value: secureStorage),

        Provider<CatApi>(
          create: (context) => CatApi(context.read<http.Client>()),
        ),
        Provider<CatRepository>(
          create: (context) => CatRepository(
            context.read<CatApi>(),
          ),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            secureStorage: context.read<FlutterSecureStorage>(),
            sharedPreferences: context.read<SharedPreferences>(),
          ),
        ),

        Provider<SignUpUseCase>(
          create: (context) => SignUpUseCase(
            context.read<AuthRepository>(),
          ),
        ),
        Provider<SignInUseCase>(
          create: (context) => SignInUseCase(
            context.read<AuthRepository>(),
          ),
        ),
        Provider<SignOutUseCase>(
          create: (context) => SignOutUseCase(
            context.read<AuthRepository>(),
          ),
        ),
        Provider<GetCurrentUserUseCase>(
          create: (context) => GetCurrentUserUseCase(
            context.read<AuthRepository>(),
          ),
        ),

        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            signUpUseCase: context.read<SignUpUseCase>(),
            signInUseCase: context.read<SignInUseCase>(),
            signOutUseCase: context.read<SignOutUseCase>(),
            getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
          ),
        ),
        ChangeNotifierProvider<CatProvider>(
          create: (context) => CatProvider(
            context.read<CatRepository>(),
          )..loadRandomCat(),
        ),
        ChangeNotifierProvider<BreedsProvider>(
          create: (context) => BreedsProvider(
            context.read<CatRepository>(),
          )..loadAllBreeds(),
        ),
      ],
      child: MaterialApp(
        title: 'Кототиндер Про',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!onboardingCompleted) {
              return const OnboardingPage();
            }

            if (!authProvider.isAuthenticated) {
              return const AuthPage();
            }

            return const MainNavigationPage();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}