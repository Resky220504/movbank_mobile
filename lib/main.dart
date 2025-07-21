// lib/main.dart

import 'package:flutter/material.dart';
import 'package:movbank_mobile/theme/app_theme.dart';
import 'package:movbank_mobile/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/novo_investimento_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create:
          (_) => ThemeNotifier(
            ThemeMode.dark,
          ), // Define o tema inicial como escuro
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'App Financeiro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.getThemeMode(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/novo_investimento': (context) => const NovoInvestimentoScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
