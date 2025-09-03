import 'package:pedeai/Commom/nomeAparelho.dart';
import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/caixaController.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/script/scriptVenda.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class VendaController {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final ScriptVenda _script = ScriptVenda();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();
  final UsuarioController usuarioController = UsuarioController();
  final CaixaCotroller caixaController = CaixaCotroller();
  final formato = DateFormat('yyyy-MM-dd');

  Future<List<Map<String, dynamic>>> listarVendas({DateTime? inicio, DateTime? fim}) async {
    final empresa = await empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');

    String sql = _script.buscarVendas(empresa.schema, formato.format(inicio!), formato.format(fim!));
    try {
      final result = await _databaseService.executeSql2(sql, schema: empresa.schema);
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Erro ao listar vendas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> buscarItensDaVenda(int idVenda) async {
    final empresa = await empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');

    String sql = _script.buscarItensDaVenda(empresa.schema, idVenda);
    try {
      final result = await _databaseService.executeSql2(sql, schema: empresa.schema);
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Erro ao listar vendas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> buscarFormasDePagamentoDaVenda(int idVenda) async {
    final empresa = await empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');

    String sql = _script.buscarFormasDePagamentoDaVenda(empresa.schema, idVenda);
    try {
      final result = await _databaseService.executeSql2(sql, schema: empresa.schema);
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Erro ao listar vendas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> buscarDadosDaVenda(int idVenda) async {
    final empresa = await empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');

    String sql = _script.buscarDadosDaVenda(empresa.schema, idVenda);
    try {
      final result = await _databaseService.executeSql2(sql, schema: empresa.schema);
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Erro ao listar vendas: $e');
    }
  }

  Future<void> inserirVendaPdv({required Map<String, dynamic> dadosVenda, required List<Map<String, dynamic>> dadosVendaItens, required List<Map<String, dynamic>> dadosFormaPagamento, required List<Map<String, dynamic>> dadosMovimentacaoEstoque}) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String? uidUsuario = await usuarioController.getUidUsuarioFromSharedPreferences();
      final nomeDispositivo = await getDeviceName();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      // Ajustes na venda
      dadosVenda['id_empresa'] = empresa.id;
      dadosVenda['uid_venda'] = const Uuid().v4();
      dadosVenda['uid_usuario_abriu_venda'] = uidUsuario;
      dadosVenda['uid_usuario_fechou_venda'] = uidUsuario;
      dadosVenda['id_caixa'] = await caixaController.getIdCaixaFromSharedPreferences();
      dadosVenda['terminal_abertura'] = nomeDispositivo;
      dadosVenda['terminal_fechamento'] = nomeDispositivo;

      // Itens da venda
      for (var item in dadosVendaItens) {
        item['uid_usuario_lancou'] = uidUsuario;
      }

      // Itens do caixa
      for (var item in dadosFormaPagamento) {
        item['id_empresa'] = empresa.id;
        item['id_caixa'] = await caixaController.getIdCaixaFromSharedPreferences();
      }

      await _databaseService.executeSqlInserirVendaPdv(schema: empresa.schema, venda: dadosVenda, itensVenda: dadosVendaItens, itensCaixa: dadosFormaPagamento, itensEstoque: dadosMovimentacaoEstoque);
    } catch (e) {
      throw Exception('Erro ao inserir venda: $e');
    }
  }

  Future<void> cancelarVenda(int idVenda) async {
    try {
      final empresa = await empresaController.getEmpresaFromSharedPreferences();
      if (empresa == null) throw Exception('Empresa não encontrada');

      await _databaseService.cancelarVendaFunction(
        schemaEmpresa: empresa.schema,
        idVenda: idVenda,
      );
    } catch (e) {
      throw Exception('Erro ao cancelar venda: $e');
  }
}
}
