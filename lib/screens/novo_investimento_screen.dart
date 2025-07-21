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

  IpcaProjecaoMensal({
    required this.dataReferenciaMesAno,
    required this.mediana,
  });

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
  final TextEditingController _porcentagemIpcaController =
      TextEditingController();

  String _resultadoPrevisto = 'Resultado previsto';

  @override
  void dispose() {
    _valorController.dispose();
    _periodoController.dispose();
    _porcentagemIpcaController.dispose();
    super.dispose();
  }

  Future<double> fetchSelicTax() async {
    final url = Uri.parse(
      'https://api.bcb.gov.br/dados/serie/bcdata.sgs.1178/dados?formato=json&dataInicial=01/01/2025',
    );
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
    final url = Uri.parse(
      r"https://olinda.bcb.gov.br/olinda/servico/Expectativas/versao/v1/odata/ExpectativaMercadoMensais?$top=100&$filter=Indicador%20eq%20'IPCA'%20and%20contains(DataReferencia%2C'2026')&$orderby=Data%20desc&$format=json"
          .toString(),
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      final List<dynamic> rawProjections =
          decodedJson['value'] as List<dynamic>;
      final Map<String, IpcaProjecaoMensal> latestProjectionsMap = {};

      for (var item in rawProjections) {
        final projecao = IpcaProjecaoMensal.fromJson(
          item as Map<String, dynamic>,
        );
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
      print(
        'Aviso: O cálculo pode ser menos preciso para prazos muito longos (acima de 48 meses).',
      );
    }

    double valorAtual = valorInicial;
    final DateFormat formatter = DateFormat('MM/yyyy');

    double ganhoRealAnualDecimal = ganhoRealAnualPorcentagem / 100;
    double ganhoRealMensal = pow((1 + ganhoRealAnualDecimal), (1 / 12)) - 1;

    final Map<String, double> ipcaProjecaoMap = {
      for (var proj in todasProjecoesIpcaMensais)
        proj.dataReferenciaMesAno: proj.mediana,
    };

    for (int i = 0; i < prazoEmMeses; i++) {
      DateTime mesProjecao = DateTime(
        dataInicioInvestimento.year,
        dataInicioInvestimento.month + 1 + i,
        1,
      );
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

    final double? valor = double.tryParse(
      _valorController.text.replaceAll(',', '.'),
    );
    final int? periodo = int.tryParse(_periodoController.text);
    final double taxa = double.tryParse(_porcentagemIpcaController.text) ?? 0.0;
    final String? tipoTaxa = _tipoTaxaSelecionada;

    if (valor == null ||
        valor <= 0 ||
        periodo == null ||
        periodo <= 0 ||
        tipoTaxa == null) {
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

    try {
      switch (tipoTaxa) {
        case 'Pós-fixado':
          taxaAnual = (await fetchSelicTax() * (taxa / 100)) / 100;
          resultado =
              valor *
              pow(1 + pow(1 + taxaAnual, 1 / 12) - 1, periodo.toDouble());
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar dados: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() {
        _resultadoPrevisto = 'Erro no cálculo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Acessa o tema e os estilos de texto definidos
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo investimento'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Este cabeçalho é decorativo e mantém a aparência nos dois temas
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    image: DecorationImage(
                      image: const AssetImage(
                        'assets/images/background-header.png',
                      ),
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
                  child: Image.asset('assets/images/LOGO.png', height: 40.0),
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
                  // Removido o método _buildTextFieldWithLabel para usar o tema diretamente
                  TextFormField(
                    controller: _valorController,
                    decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  TextFormField(
                    controller: _periodoController,
                    decoration: const InputDecoration(
                      labelText: 'Período (meses)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20.0),

                  // Rótulo para o Dropdown usando o estilo do tema
                  Text('Tipo de taxa', style: textTheme.bodyLarge),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _tipoTaxaSelecionada,
                    hint: const Text('Selecione...'),
                    isExpanded: true,
                    // A decoração aqui herda do inputDecorationTheme que definimos
                    decoration: const InputDecoration(),
                    // A cor do dropdown agora vem do tema
                    dropdownColor: theme.colorScheme.surfaceVariant,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      // A cor do ícone também vem do tema
                      color: theme.iconTheme.color,
                    ),
                    items:
                        _tiposDeTaxa.map((String value) {
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

                  TextFormField(
                    controller: _porcentagemIpcaController,
                    decoration: const InputDecoration(labelText: 'Taxa (%)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+[\.,]?\d{0,2}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),

                  ElevatedButton(
                    onPressed: _calcularInvestimento,
                    // O estilo do botão já é controlado pelo tema
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Calcular'),
                  ),
                  const SizedBox(height: 30.0),

                  // Container de resultado adaptado ao tema
                  Container(
                    width: double.infinity,
                    height: 100,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      // Usa a cor do card do tema para o fundo
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        // Usa a cor primária com opacidade para a borda
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _resultadoPrevisto,
                        style: textTheme.headlineSmall?.copyWith(
                          // Usa a cor primária para sucesso, e a cor padrão para outros textos
                          color:
                              _resultadoPrevisto.startsWith('R\$')
                                  ? theme.colorScheme.primary
                                  : textTheme.bodySmall?.color,
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
