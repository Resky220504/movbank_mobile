import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 2. Criar controllers para os campos de texto
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  // 3. Criar uma chave global para o formulário para podermos validá-lo
  final _formKey = GlobalKey<FormState>();

  // 4. Limpa os controllers quando a tela for destruída
  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      // 5. Envolver a coluna com um widget Form e associar a nossa chave
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/LOGO.png',
                  height: 160.00,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.monetization_on_outlined,
                        size: 100.0,
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 50.0), // Campo Usuário
                TextFormField(
                  controller: _userController, // 6. Associar o controller
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ), // Ícone para o campo
                    border: OutlineInputBorder(), // Borda para o campo
                  ),
                  keyboardType: TextInputType.text,
                  // 7. Adicionar lógica de validação
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu usuário';
                    }
                    return null; // Retorna null se for válido
                  },
                ),
                const SizedBox(height: 20.0),

                // Campo Senha
                TextFormField(
                  controller: _passwordController, // 8. Associar o controller
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline), // Ícone para o campo
                    border: OutlineInputBorder(), // Borda para o campo
                  ),
                  obscureText: true, // Esconde a senha
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite sua senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres';
                    }
                    return null; // Retorna null se for válido
                  },
                ),
                const SizedBox(height: 40.0),

                // Botão Entrar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // 9. Lógica de login aqui
                    // Primeiro, verifica se o formulário é válido
                    if (_formKey.currentState!.validate()) {
                      // Se for válido, podemos pegar os dados e fazer o login
                      String username = _userController.text;
                      String password = _passwordController.text;

                      print("Botão Entrar Pressionado");
                      print("Usuário: $username");
                      print("Senha: $password");

                      // TODO: Implementar a lógica de autenticação real aqui
                      // Por enquanto, apenas navegamos para a home

                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 20.0),

                // Divisor OU ... (seu código aqui estava perfeito)
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

                // Botão Cadastre-se
                OutlinedButton(
                  // Mudei para OutlinedButton para diferenciar do principal
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.limeAccent,
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
