import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/script/scriptCaixa.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaixaCotrollerException implements Exception {
  String message;
  CaixaCotrollerException(this.message);
}

class CaixaCotroller {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  late SharedPreferences prefs;
  final ScriptCaixa _scriptCaixa = ScriptCaixa();
  final EmpresaController empresaController = EmpresaController();
  final UsuarioController usuarioController = UsuarioController();

  Future<void> _salvarIdCaixaSharedPreferences(int idCaixa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_caixa', idCaixa);
  }

  Future<int> abrirCaixa(double valor, String periodo) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String? uidUsuario = await usuarioController.getUidUsuarioFromSharedPreferences();

      String sql = _scriptCaixa.inserirCaixa(empresa!.schema, {'aberto': true, 'data_abertura': DateTime.now(), 'id_usuario_abertura': "'$uidUsuario'", 'valor_abertura': valor, 'periodo_abertura': "'$periodo'"});
      final resultado = await _databaseService.executeSql(sql, schema: empresa.schema);
      int idCaixa = resultado.first['id'] as int;
      if (idCaixa != null && idCaixa != -1) {
        await _salvarIdCaixaSharedPreferences(idCaixa);
      }
      return idCaixa;
    } catch (e) {
      print('Erro ao abrir caixa: $e');
      return -1;
    }
  }

  Future<int> buscarCaixaAberto() async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String sql = _scriptCaixa.buscarCaixaAberto(empresa!.schema);
      final resultado = await _databaseService.executeSql(sql, schema: empresa.schema);
      int idCaixa = resultado.first['id'] as int;
      if (idCaixa != null && idCaixa != -1) {
        await _salvarIdCaixaSharedPreferences(idCaixa);
      }
      return idCaixa;
    } catch (e) {
      print('Erro ao buscar caixa aberta: $e');
      return -1;
    }
  }

  Future<int?> getIdCaixaFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_caixa');
  }
}
