import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<String> fetchSelicTax() async {
    final url = Uri.parse('https://api.bcb.gov.br/dados/serie/bcdata.sgs.1178/dados?formato=json&dataInicial=01/01/2025');
    final response = await http.get(url);

    if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    
    if (data.isNotEmpty && data.last['valor'] != null) {
      return data.last['valor'].toString();
    } else {
      throw Exception('Lista vazia ou valor não encontrado');
    }
  } else {
    throw Exception('Erro na requisição: ${response.statusCode}');
  }
}

Future<String> fetchIpcaTax() async {
    final url = Uri.parse('https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json&dataInicial=01/01/2025');
    final response = await http.get(url);

    if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    
    if (data.isNotEmpty && data.last['valor'] != null) {
      return data.last['valor'].toString();
    } else {
      throw Exception('Lista vazia ou valor não encontrado');
    }
  } else {
    throw Exception('Erro na requisição: ${response.statusCode}');
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late Future<String> _selicTaxFuture;
  late Future<String> _ipcaTaxFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the futures when the widget is created
    _selicTaxFuture = fetchSelicTax();
    _ipcaTaxFuture = fetchIpcaTax();
  }

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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

                FutureBuilder<String>(
                  future: _selicTaxFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildTaxaCard(context, 'Taxa SELIC', 'Carregando...');
                    } else if (snapshot.hasError) {
                      return _buildTaxaCard(context, 'Taxa SELIC', 'Erro: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return _buildTaxaCard(context, 'Taxa SELIC', '${snapshot.data}%');
                    }
                    return _buildTaxaCard(context, 'Taxa SELIC', 'N/A');
                  },
                ),

                FutureBuilder<String>(
                  future: _ipcaTaxFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildTaxaCard(context, 'Taxa IPCA', 'Carregando...');
                    } else if (snapshot.hasError) {
                      return _buildTaxaCard(context, 'Taxa IPCA', 'Erro: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return _buildTaxaCard(context, 'Taxa IPCA', '${snapshot.data}%');
                    }
                    return _buildTaxaCard(context, 'Taxa IPCA', 'N/A');
                  },
                ),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
