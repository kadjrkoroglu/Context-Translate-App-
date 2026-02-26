import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/pages/auth/auth_wrapper.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:translate_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:translate_app/theme/theme_provider.dart';
import 'package:translate_app/theme/theme.dart';
import 'package:translate_app/presentation/viewmodels/main_viewmodel.dart';
import 'package:translate_app/presentation/viewmodels/gemini_translate_viewmodel.dart';
import 'package:translate_app/presentation/viewmodels/ml_translate_viewmodel.dart';
import 'package:translate_app/presentation/viewmodels/history_viewmodel.dart';
import 'package:translate_app/presentation/viewmodels/decks_viewmodel.dart';
import 'package:translate_app/data/services/local_storage_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate_app/data/services/settings_service.dart';

import 'package:translate_app/data/services/auth_service.dart';
import 'package:translate_app/data/repositories/auth_repository.dart';
import 'package:translate_app/presentation/viewmodels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final localStorage = LocalStorageService();
  await localStorage.init();

  final authService = AuthService();
  final authRepository = AuthRepository(authService);

  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  final envString = await rootBundle.loadString('env.json');
  final envMap = jsonDecode(envString) as Map<String, dynamic>;
  final apiKey = envMap['api_key'] as String;

  Gemini.init(apiKey: apiKey);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(settingsService)),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        Provider<SettingsService>.value(value: settingsService),
        Provider<LocalStorageService>.value(value: localStorage),
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider(
          create: (context) =>
              FavoriteViewModel(context.read<LocalStorageService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              HistoryViewModel(context.read<LocalStorageService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              DecksViewModel(context.read<LocalStorageService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => GeminiTranslateViewModel(
            context.read<SettingsService>(),
            context.read<HistoryViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MLTranslateViewModel(
            context.read<SettingsService>(),
            context.read<HistoryViewModel>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}
