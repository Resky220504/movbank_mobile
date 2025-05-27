import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Impede o botão de voltar automático
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Ícone/Logo
              Icon(
                Icons.monetization_on_outlined, // Ícone de exemplo
                size: 100.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 50.0),

              // Campo Usuário
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  // hintText: 'Digite seu usuário', // Adicionado hintText
                ),
                keyboardType: TextInputType.text,
                // TODO: Adicionar controller e lógica de validação/autenticação
              ),
              const SizedBox(height: 20.0),

              // Campo Senha
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  // hintText: 'Digite sua senha', // Adicionado hintText
                ),
                obscureText: true,
                // TODO: Adicionar controller e lógica de validação/autenticação
              ),
              const SizedBox(height: 40.0),

              // Botão Entrar
              ElevatedButton(
                onPressed: () {
                  // Lógica de login aqui (ex: ir para a tela principal)
                  print("Botão Entrar Pressionado");
                  // **Correção: Navegar para a tela Home e remover a tela de login da pilha**
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 20.0),

              // Divisor OU
              const Row(
                children: <Widget>[
                  Expanded(child: Divider()), // Cor do tema será aplicada
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OU', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()), // Cor do tema será aplicada
                ],
              ),
              const SizedBox(height: 20.0),

              // Botão Cadastre-se
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register'); // Navega para Registro
                },
                child: const Text('Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
