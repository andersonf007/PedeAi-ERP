import 'package:pedeai/repositorio/testerepositorio.dart';

class Testecontroller {
  final Testerepositorio _repositorio;

  Testecontroller({required Testerepositorio repositorio}) : _repositorio = repositorio;

  Future<int> inserirTeste(String nome, String schema) async {
    return await _repositorio.inserirTeste(nome, schema);
  }
}