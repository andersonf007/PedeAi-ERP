import 'package:pedeai/Commom/nomeAparelho.dart';
import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class VendaController {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();
  final UsuarioController usuarioController = UsuarioController();

  Future<void> inserirVendaPdv(Map<String, dynamic> dadosVenda, Map<String, dynamic> dadosVendaItem, Map<String, dynamic> dadosFormaPagamento) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String? uidUsuario = await usuarioController.getUidUsuarioFromSharedPreferences();
      if (empresa == null) {
        throw Exception('dadosVenda da empresa não encontrados');
      }
      dadosVenda['id_empresa'] = empresa.schema;
      dadosVenda['uid_venda'] = Uuid().v4();
      dadosVenda['uid_usuario_abriu_venda'] = uidUsuario;
      dadosVenda['uid_usuario_fechou_venda'] = uidUsuario;
      dadosVenda['id_caixa'] = null; // BUSCAR ID DO CAIXA
      dadosVenda['terminal_abertura'] = await getDeviceName();
      dadosVenda['terminal_fechamento'] = await getDeviceName();
      dadosVendaItem['uid_usuario_lancou'] = uidUsuario;
      dadosFormaPagamento['id_empresa'] = empresa.schema;
      dadosFormaPagamento['id_caixa'] = null;
    } catch (e) {
      print('Erro ao inserir produto: $e');
      throw Exception('Erro ao inserir produto: $e');
    }
  }
}
