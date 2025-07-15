import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';


class NovoInvestimentoScreen extends StatefulWidget {
  const NovoInvestimentoScreen({super.key});

  @override
  State<NovoInvestimentoScreen> createState() => _NovoInvestimentoScreenState();
}

class IpcaProjecaoMensal {
  final String dataReferenciaMesAno;
  final double mediana;

  IpcaProjecaoMensal({required this.dataReferenciaMesAno, required this.mediana});

  factory IpcaProjecaoMensal.fromJson(Map<String, dynamic> json) {
    return IpcaProjecaoMensal(
      dataReferenciaMesAno: json['DataReferencia'] as String,
      mediana: json['Mediana'] as double,
    );
  }
}

class _NovoInvestimentoScreenState extends State<NovoInvestimentoScreen> {
  String? _tipoTaxaSelecionada;
  final List<String> _tiposDeTaxa = ['Pós-fixado', 'IPCA'];
  
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _porcentagemIpcaController = TextEditingController();

  String _resultadoPrevisto = 'Resultado previsto'; 

  @override
  void dispose() {
    _valorController.dispose();
    _periodoController.dispose();
    _porcentagemIpcaController.dispose();
    super.dispose();
  }

  Future<double> fetchSelicTax() async {
    final url = Uri.parse('https://api.bcb.gov.br/dados/serie/bcdata.sgs.1178/dados?formato=json&dataInicial=01/01/2025');
    final response = await http.get(url);

    if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    
    if (data.isNotEmpty && data.last['valor'] != null) {
      return double.parse(data.last['valor']);
    } else {
      throw Exception('Lista vazia ou valor não encontrado');
    }
  } else {
    throw Exception('Erro na requisição: ${response.statusCode}');
  }
}

Future<List<IpcaProjecaoMensal>> fetchIpcaTax() async {
    final url = Uri.parse(r"https://olinda.bcb.gov.br/olinda/servico/Expectativas/versao/v1/odata/ExpectativaMercadoMensais?$top=100&$filter=Indicador%20eq%20'IPCA'%20and%20contains(DataReferencia%2C'2026')&$orderby=Data%20desc&$format=json".toString());
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      final List<dynamic> rawProjections = decodedJson['value'] as List<dynamic>;
      final Map<String, IpcaProjecaoMensal> latestProjectionsMap = {};
      
      for (var item in rawProjections) {
        final projecao = IpcaProjecaoMensal.fromJson(item as Map<String, dynamic>);
        if (!latestProjectionsMap.containsKey(projecao.dataReferenciaMesAno)) {
          latestProjectionsMap[projecao.dataReferenciaMesAno] = projecao;
        }
      }
      return latestProjectionsMap.values.toList();
    } else {
    throw Exception('Erro na requisição: ${response.statusCode}');
  }
}

 Future<double> calcularValorFinalCdbIpcaMaisCompleto({
  required double valorInicial,
  required double ganhoRealAnualPorcentagem,
  required int prazoEmMeses,
  required DateTime dataInicioInvestimento,
  required List<IpcaProjecaoMensal> todasProjecoesIpcaMensais,
}) async {
  if (prazoEmMeses <= 0) {
    return valorInicial;  
  }
  if (prazoEmMeses > 48) {
    print('Aviso: O cálculo pode ser menos preciso para prazos muito longos (acima de 48 meses).');
  }

  double valorAtual = valorInicial;
  final DateFormat formatter = DateFormat('MM/yyyy');

  double ganhoRealAnualDecimal = ganhoRealAnualPorcentagem / 100;
  double ganhoRealMensal = pow((1 + ganhoRealAnualDecimal), (1 / 12)) - 1;

  final Map<String, double> ipcaProjecaoMap = {
    for (var proj in todasProjecoesIpcaMensais) proj.dataReferenciaMesAno: proj.mediana
  };

  for (int i = 0; i < prazoEmMeses; i++) {
    DateTime mesProjecao = DateTime(dataInicioInvestimento.year, dataInicioInvestimento.month + 1 + i, 1);
    String keyMesProjecao = formatter.format(mesProjecao);

    double ipcaDoMesPorcentagem = ipcaProjecaoMap[keyMesProjecao] ?? 0.0;

    double ipcaDoMesDecimal = ipcaDoMesPorcentagem / 100;

    valorAtual *= (1 + ipcaDoMesDecimal);
    valorAtual *= (1 + ganhoRealMensal);
  }

  return valorAtual;
}

  void _calcularInvestimento() async {
    FocusScope.of(context).unfocus(); 

    final double? valor = double.tryParse(_valorController.text.replaceAll(',', '.')); 
    final int? periodo = int.tryParse(_periodoController.text);
    final double taxa = double.tryParse(_porcentagemIpcaController.text) ?? 0.0;
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
    double resultado = 0.0;

    switch (tipoTaxa) {
      case 'Pós-fixado':
        taxaAnual = (await fetchSelicTax() * (taxa/100))/100;
        resultado = valor * pow(1 + pow(1 + taxaAnual, 1 / 12) - 1, periodo.toDouble());
        break;
      case 'IPCA':
        resultado = await calcularValorFinalCdbIpcaMaisCompleto(
          valorInicial: valor,
          ganhoRealAnualPorcentagem: taxa,
          prazoEmMeses: periodo,
          dataInicioInvestimento: DateTime.now(),
          todasProjecoesIpcaMensais: await fetchIpcaTax(),
        );
        break;
    }    

    setState(() {
      _resultadoPrevisto = 'R\$ ${resultado.toStringAsFixed(2)}';
    });
  }

  Widget _buildTextFieldWithLabel(String label, TextInputType keyboardType, TextEditingController controller, {
    List<TextInputFormatter>? inputFormatters,
    }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller, 
          decoration: InputDecoration(
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
                      image: const AssetImage('assets/images/background-header.png'),
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

                  const SizedBox(height: 20.0),
                  _buildTextFieldWithLabel(
                    'Taxa (%)',
                    const TextInputType.numberWithOptions(decimal: true),
                    _porcentagemIpcaController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.]?\d{0,2}')),
                    ],
                  ),
                  
                  const SizedBox(height: 20.0),

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
    );
  }
}
