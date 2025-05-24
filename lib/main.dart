import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/novo_investimento_screen.dart'; // <-- IMPORTE A NOVA TELA

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... (seu tema continua aqui, igual ao anterior)
      title: 'App Financeiro',
      theme: ThemeData( /* ... Seu tema ... */ ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/novo_investimento': (context) => const NovoInvestimentoScreen(), // <-- ADICIONE A ROTA
      },
    );
  }
}