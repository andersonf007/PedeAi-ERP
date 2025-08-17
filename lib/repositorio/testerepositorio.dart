import 'package:pedeai/IHttpService.dart';

class Testerepositorio {

  final IHttpService _http;
  Testerepositorio({required IHttpService http}) : _http = http;

  Future<int> inserirTeste(String nome, String schema) async {
    final response = await _http.get(url: '/teste/inserir?nome=$nome', nomeWebSocketAtual: 'fenix', schema: schema);
    if (response.statusCode == 200) {
      if (response.data is String) {
        throw Exception('Erro ao inserir teste: ${response.data}');
      } else {
        return response.data;
      }
    } else {
      throw Exception('Erro ao inserir teste: ${response.statusCode}');
    }
  }
}