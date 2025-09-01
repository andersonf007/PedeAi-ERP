import 'package:pedeai/Commom/nomeAparelho.dart';
import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/caixaController.dart';
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
  final CaixaCotroller caixaController = CaixaCotroller();

Future<void> inserirVendaPdv({
  required Map<String, dynamic> dadosVenda,
  required List<Map<String, dynamic>> dadosVendaItens,
  required List<Map<String, dynamic>> dadosFormaPagamento,
  required List<Map<String, dynamic>> dadosMovimentacaoEstoque,
}) async {
  try {
    Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
    String? uidUsuario = await usuarioController.getUidUsuarioFromSharedPreferences();
    if (empresa == null) {
      throw Exception('Dados da empresa não encontrados');
    }

    // --- Ajustes na VENDA ---
    dadosVenda['id_empresa'] = empresa.id;
    dadosVenda['uid_venda'] = Uuid().v4();
    dadosVenda['uid_usuario_abriu_venda'] = uidUsuario;
    dadosVenda['uid_usuario_fechou_venda'] = uidUsuario;
    dadosVenda['id_caixa'] = await caixaController.getIdCaixaFromSharedPreferences();
    dadosVenda['terminal_abertura'] = await getDeviceName();
    dadosVenda['terminal_fechamento'] = await getDeviceName();

    // --- Ajustes nos ITENS DA VENDA ---
    for (var item in dadosVendaItens) {
      item['uid_usuario_lancou'] = uidUsuario;
    }

    // --- Ajustes nos ITENS DO CAIXA ---
    for (var item in dadosFormaPagamento) {
      item['id_empresa'] = empresa.id;
      item['id_caixa'] = await caixaController.getIdCaixaFromSharedPreferences();
    }

    
    final idVenda = await _databaseService.executeSqlInserirVendaPdv(
      schema: empresa.schema,
      venda: dadosVenda,
      itensVenda: dadosVendaItens,
      itensCaixa: dadosFormaPagamento,
      itensEstoque: dadosMovimentacaoEstoque,
    );

    print('Venda inserida com sucesso. ID: $idVenda');
  } catch (e) {
    print('Erro ao inserir venda: $e');
    throw Exception('Erro ao inserir venda: $e');
  }
}

}
