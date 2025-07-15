import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

Future<List<String>> fetchSelicTax() async {
  final url = Uri.parse('https://api.bcb.gov.br/dados/serie/bcdata.sgs.1178/dados?formato=json&dataInicial=01/03/2025&dataFinal=14/04/2025');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    log(data);
    // Supondo que a resposta seja uma lista de strings:
    return List<String>.from(data);
  } else {
    throw Exception('Falha ao carregar os tipos de taxa');
  }
}

Future<List<String>> fetchIpcaTax() async {
  final url = Uri.parse('https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json&dataInicial=01/01/2025&dataFinal=14/04/2025 ');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    log(data);
    // Supondo que a resposta seja uma lista de strings:
    return List<String>.from(data);
  } else {
    throw Exception('Falha ao carregar os tipos de taxa');
  }
}