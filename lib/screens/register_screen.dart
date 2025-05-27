import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        centerTitle: true,
        leading: IconButton( // Adiciona um botão de voltar automático
          icon: Icon(Icons.adaptive.arrow_back), // Ícone adaptativo (iOS/Android)
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Ícone/Logo
              // Substituído o Icon pelo Image.asset
              Image.asset(
                'assets/images/LOGO.png', // Caminho para sua logo
                height: 100.0, // Ajuste a altura conforme necessário
              ),
              const SizedBox(height: 50.0),

              // Campo Usuário
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                ),
                keyboardType: TextInputType.text,
                // TODO: Adicionar controller e lógica de validação/autenticação
              ),
              const SizedBox(height: 20.0),

              // Campo Senha
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
                obscureText: true,
                // TODO: Adicionar controller e lógica de validação/autenticação
              ),
              const SizedBox(height: 20.0),

              // Campo Confirmar Senha
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirme sua senha',
                ),
                obscureText: true,
                // TODO: Adicionar controller e lógica de validação/autenticação
              ),
              const SizedBox(height: 40.0),

              // Botão Criar conta
              ElevatedButton(
                onPressed: () {
                  // Lógica de registro aqui (ex: salvar e ir para login/home)
                  print("Botão Criar Conta Pressionado");
                  // TODO: Implementar lógica de registro real
                  Navigator.pop(context); // Volta para a tela anterior (Login)
                },
                child: const Text('Criar conta'),
              ),
              const SizedBox(height: 20.0),

              // Divisor OU
              const Row(
                children: <Widget>[
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OU', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20.0),

              // Botão Entrar
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Volta para a tela de login
                },
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}