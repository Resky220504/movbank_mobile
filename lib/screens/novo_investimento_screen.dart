import 'package:flutter/material.dart';
import 'dart:math'; 

class NovoInvestimentoScreen extends StatefulWidget {
  const NovoInvestimentoScreen({super.key});

  @override
  State<NovoInvestimentoScreen> createState() => _NovoInvestimentoScreenState();
}

class _NovoInvestimentoScreenState extends State<NovoInvestimentoScreen> {
  int _selectedIndex = -1; 
  String? _tipoTaxaSelecionada;
  final List<String> _tiposDeTaxa = ['SELIC', 'IPCA', 'Pré-fixada', 'Pós-fixada'];
  
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();
  String _resultadoPrevisto = 'Resultado previsto'; 

  @override
  void dispose() {
    _valorController.dispose();
    _periodoController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) { 
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (index == 1) { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tela de Ajustes ainda não implementada.'),
            duration: Duration(seconds: 1),
          ),
        );
        _selectedIndex = -1; 
      } else if (index == 2) { 
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  void _calcularInvestimento() {
    FocusScope.of(context).unfocus(); 

    final double? valor = double.tryParse(_valorController.text.replaceAll(',', '.')); 
    final int? periodo = int.tryParse(_periodoController.text);
    final String? tipoTaxa = _tipoTaxaSelecionada;

    if (valor == null || valor <= 0 || periodo == null || periodo <= 0 || tipoTaxa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos corretamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
         _resultadoPrevisto = 'Erro na entrada';
      });
      return;
    }

    double taxaAnual = 0.0;
    // TODO: Buscar taxas reais de uma API ou configuração
    switch (tipoTaxa) {
      case 'SELIC':
        taxaAnual = 0.1050; // Exemplo: 10.50% a.a. (valor atual da Selic em Maio/2024 era ~10.50%)
        break;
      case 'IPCA':
        taxaAnual = 0.0380; // Exemplo: IPCA acumulado 12 meses ~3.80% (Maio/2024) + spread (ex: +5% = 0.0880)
        // Para IPCA + X%, você precisaria de outro campo para o X% ou um valor fixo de spread.
        // Aqui, vamos simular IPCA + 5% = 0.0380 (IPCA) + 0.05 (spread) = 0.0880
        taxaAnual = 0.0380 + 0.05; // IPCA + 5%
        break;
      case 'Pré-fixada':
        taxaAnual = 0.11; // Exemplo: 11% a.a.
        break;
      case 'Pós-fixada':
        // Geralmente atrelada a um % do CDI. CDI é próximo da SELIC.
        // Exemplo: 100% do CDI (CDI ~ SELIC - 0.10%)
        double cdiEstimado = 0.1040; // Exemplo: 10.40% a.a.
        taxaAnual = cdiEstimado * 1.0; // 100% do CDI
        break;
    }

    double taxaMensal = pow(1 + taxaAnual, 1 / 12) - 1;
    double resultado = valor * pow(1 + taxaMensal, periodo.toDouble()); // periodo precisa ser double para pow

    setState(() {
      _resultadoPrevisto = 'R\$ ${resultado.toStringAsFixed(2)}';
    });
  }

  Widget _buildTextFieldWithLabel(String label, TextInputType keyboardType, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller, 
          decoration: InputDecoration(
             // Estilo herdado do tema global
          ),
          keyboardType: keyboardType,
        ),
        const SizedBox(height: 20.0), 
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo investimento'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    image: DecorationImage(
                      image: const NetworkImage('https://via.placeholder.com/600x200.png/222222/FFFFFF?text=Fundo+Mercado'), // Placeholder
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 15,
                  // Substituído o Icon pelo Image.asset
                  child: Image.asset(
                    'assets/images/LOGO.png', // Caminho para sua logo
                     height: 40.0, // Ajuste a altura conforme necessário
                  ),
                ),
                const Text(
                  'Novo Investimento',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 5.0, color: Colors.black)],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTextFieldWithLabel('Valor (R\$)', const TextInputType.numberWithOptions(decimal: true), _valorController),
                  _buildTextFieldWithLabel('Período (meses)', TextInputType.number, _periodoController),

                  const Text('Tipo de taxa', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _tipoTaxaSelecionada,
                    hint: const Text('Selecione...'),
                    isExpanded: true,
                    decoration: InputDecoration( 
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: Colors.grey[850],
                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                    items: _tiposDeTaxa.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _tipoTaxaSelecionada = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 40.0),

                  ElevatedButton(
                    onPressed: _calcularInvestimento, 
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Calcular'),
                  ),
                  const SizedBox(height: 30.0),

                  Container(
                    width: double.infinity,
                    height: 100,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5))
                    ),
                    child: Center(
                      child: Text(
                        _resultadoPrevisto, 
                        style: TextStyle(
                            fontSize: 24, 
                            color: _resultadoPrevisto.startsWith('R\$') ? Colors.greenAccent : Colors.white54,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            label: 'Home', 
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
        currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex, 
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
