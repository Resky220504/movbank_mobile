import 'package:flutter/material.dart';

class NovoInvestimentoScreen extends StatefulWidget {
  const NovoInvestimentoScreen({super.key});

  @override
  State<NovoInvestimentoScreen> createState() => _NovoInvestimentoScreenState();
}

class _NovoInvestimentoScreenState extends State<NovoInvestimentoScreen> {
  int _selectedIndex = 0; // Para a BottomNavBar (pode ajustar a lógica)
  String? _tipoTaxaSelecionada; // Para o Dropdown
  final List<String> _tiposDeTaxa = ['SELIC', 'IPCA', 'Pré-fixada', 'Pós-fixada']; // Opções do Dropdown

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) { // Ex: Voltar para Home (ajuste conforme necessário)
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (index == 2) { // Sair
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      // Adicione lógica para o item 1 (Ajustes) se necessário
    });
  }

  // Widget para construir os campos de texto com label
  Widget _buildTextFieldWithLabel(String label, TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 8.0),
        TextFormField(
          decoration: InputDecoration(
            // Remove o label de dentro do campo se já temos um fora
            // labelText: label, // Opcional: pode remover
          ),
          keyboardType: keyboardType,
        ),
        const SizedBox(height: 20.0), // Espaçamento entre os campos
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo investimento'),
        centerTitle: true,
        // O botão de voltar será adicionado automaticamente pelo Navigator
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Cabeçalho com Imagem de Fundo ---
            Stack(
              alignment: Alignment.center,
              children: [
                // Imagem de Fundo (Use uma imagem sua ou um Container colorido)
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4), // Cor de fallback
                    image: DecorationImage(
                      image: const NetworkImage('https://via.placeholder.com/600x200.png/222222/FFFFFF?text=Fundo+Mercado'), // Use sua imagem aqui!
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6), // Escurece a imagem
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                // Logo e Título sobrepostos
                Positioned(
                   top: 15,
                   left: 15,
                   child: Icon(
                      Icons.monetization_on_outlined,
                      size: 40.0,
                      color: Theme.of(context).primaryColor,
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
            // --- Formulário ---
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTextFieldWithLabel('Valor', TextInputType.numberWithOptions(decimal: true)),
                  _buildTextFieldWithLabel('Período (meses)', TextInputType.number),

                  // Campo Tipo de Taxa (Dropdown)
                  const Text('Tipo de taxa', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _tipoTaxaSelecionada,
                    hint: const Text('Selecione...'),
                    isExpanded: true,
                    decoration: InputDecoration(
                       contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                       fillColor: Colors.grey[800], // Garante cor de fundo
                       filled: true,
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8.0),
                         borderSide: BorderSide.none,
                       ),
                    ),
                    dropdownColor: Colors.grey[850], // Cor do menu suspenso
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.limeAccent),
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

                  // Botão Calcular
                  ElevatedButton(
                    onPressed: () {
                      // Lógica de cálculo aqui
                      print("Calcular Pressionado");
                      // Atualizar o container de resultado
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Calcular'),
                  ),
                  const SizedBox(height: 30.0),

                  // Container Resultado
                  Container(
                    width: double.infinity,
                    height: 100, // Altura de exemplo
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Resultado previsto',
                        style: TextStyle(fontSize: 18, color: Colors.white54),
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
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.grey[850],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}