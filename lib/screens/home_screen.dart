import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Controla o item selecionado na BottomNavBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Adicione a lógica para cada item aqui (navegação ou ação)
      if (index == 2) {
         // Exemplo: Voltar para login ao clicar em Sair
         Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  // Widget para construir os cards de taxas
  Widget _buildTaxaCard(BuildContext context, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget para construir o cabeçalho da tabela de recentes
  Widget _buildRecentHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Valor', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('Taxa', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('Período', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('Resultado', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

   // Widget para construir uma linha da tabela (usando Divider como placeholder)
  Widget _buildRecentRowPlaceholder() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Divider(color: Colors.grey, height: 1),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove o botão de voltar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Ícone/Logo Centralizado
            Center(
              child: Icon(
                Icons.monetization_on_outlined, // Ícone de exemplo
                size: 80.0,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 30.0),

            // Título Resumo de Taxas
            const Text(
              'Resumo de Taxas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),

            // Cards de Taxas
            _buildTaxaCard(context, 'Taxa SELIC', '13,5%'),
            _buildTaxaCard(context, 'Taxa IPCA', '3%'),
            const SizedBox(height: 20.0),

            // Botão Novo Investimento
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 24),
              label: const Text('Novo Investimento', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                 minimumSize: const Size(double.infinity, 60), // Larga e alta
              ),
              onPressed: () {
                // Lógica para novo investimento
              },
            ),
            const SizedBox(height: 40.0),

            // Seção Cálculos Recentes
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[850], // Um pouco diferente para destacar
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    const Text(
                      'Calculos recentes',
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    _buildRecentHeader(),
                    const SizedBox(height: 10.0),
                    _buildRecentRowPlaceholder(),
                    _buildRecentRowPlaceholder(),
                    _buildRecentRowPlaceholder(),
                    _buildRecentRowPlaceholder(),
                    _buildRecentRowPlaceholder(),
                 ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Sair',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Cor do item selecionado
        unselectedItemColor: Colors.grey[600], // Cor dos itens não selecionados
        backgroundColor: Colors.grey[850], // Fundo da barra
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Garante que todos os labels apareçam
        showUnselectedLabels: true, // Mostra labels não selecionados
      ),
    );
  }
}