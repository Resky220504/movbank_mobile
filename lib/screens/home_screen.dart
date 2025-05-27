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
      if (index == 2) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else if (index == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tela de Perfil ainda não implementada.'),
              duration: Duration(seconds: 1)),
        );
        _selectedIndex = 0; 
      } else if (index == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tela de Ajustes ainda não implementada.'),
              duration: Duration(seconds: 1)),
        );
         _selectedIndex = 0;
      }
    });
  }

  Widget _buildTaxaCard(BuildContext context, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Valor',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('Taxa',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('Período',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('Resultado',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentRowPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('R\$ 1000,00', style: TextStyle(color: Colors.white)),
          Text('13,5%', style: TextStyle(color: Colors.white)),
          Text('12m', style: TextStyle(color: Colors.white)),
          Text('R\$ 1135,00', style: TextStyle(color: Colors.greenAccent)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              // Substituído o Icon pelo Image.asset
              child: Image.asset(
                'assets/images/LOGO.png', // Caminho para sua logo
                height: 80.0, // Ajuste a altura conforme necessário
              ),
            ),
            const SizedBox(height: 30.0),

            const Text(
              'Resumo de Taxas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),

            _buildTaxaCard(context, 'Taxa SELIC', '13,5%'), // TODO: Usar valores dinâmicos
            _buildTaxaCard(context, 'Taxa IPCA', '3%'),    // TODO: Usar valores dinâmicos
            const SizedBox(height: 20.0),

            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 24),
              label: const Text('Novo Investimento',
                  style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60), 
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/novo_investimento');
              },
            ),
            const SizedBox(height: 40.0),

            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[850], 
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
                  const Divider(color: Colors.grey, height: 20),
                  // TODO: Substituir por uma lista dinâmica de cálculos reais
                  _buildRecentRowPlaceholder(),
                  const Divider(color: Colors.grey, height: 1),
                  _buildRecentRowPlaceholder(),
                  const Divider(color: Colors.grey, height: 1),
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
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
        showUnselectedLabels: true, 
      ),
    );
  }
}
