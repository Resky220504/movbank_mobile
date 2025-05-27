import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/novo_investimento_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Financeiro',
      // Correção: Adicionado um ThemeData escuro e consistente
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.limeAccent, 
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.grey[800],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.limeAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.limeAccent),
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.grey[800],
            hintStyle: const TextStyle(color: Colors.white54),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
         bottomNavigationBarTheme: BottomNavigationBarThemeData(
             backgroundColor: Colors.grey[850],
             selectedItemColor: Colors.limeAccent,
             unselectedItemColor: Colors.grey[600],
         ),
         iconTheme: const IconThemeData(color: Colors.limeAccent),
         textTheme: const TextTheme(
           bodyLarge: TextStyle(color: Colors.white),
           bodyMedium: TextStyle(color: Colors.white70),
           titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
           titleMedium: TextStyle(color: Colors.white),
         ),
         dividerColor: Colors.grey[700],
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/novo_investimento': (context) => const NovoInvestimentoScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}