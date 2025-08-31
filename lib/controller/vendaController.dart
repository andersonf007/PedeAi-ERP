import 'package:pedeai/Commom/nomeAparelho.dart';
import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/controller/usuarioController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/script/scriptVenda.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class VendaController {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final ScriptVenda _script = ScriptVenda();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();
  final UsuarioController usuarioController = UsuarioController();

  // Lista vendas com filtro opcional por período (usa função ADMIN para evitar bloqueio de schema)
  Future<List<Map<String, dynamic>>> listarVendasResumo({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    final empresa = await empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');

    // 1) Detecta tabela/view candidata nos schemas da empresa e public
    String? fonte;
    String? fonteSchema;
    try {
      final detectSql = """
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema IN ('${empresa.schema}', 'public')
          AND (table_name IN ('vw_vendas_resumo','vendas','venda') OR table_name ILIKE '%venda%' OR table_name ILIKE '%pedido%')
        ORDER BY CASE table_name
          WHEN 'vw_vendas_resumo' THEN 0
          WHEN 'vendas' THEN 1
          WHEN 'venda' THEN 2
          ELSE 10 END, table_name
        LIMIT 1
      """;
      final r = await _databaseService.executeSqlListar(sql: detectSql);
      if (r.isNotEmpty) {
        fonteSchema = (r.first['table_schema'] ?? '').toString();
        fonte = (r.first['table_name'] ?? '').toString();
      }
    } catch (_) {}

    // Fallback: tenta nomes padrões no schema da empresa
    if (fonte == null || fonte.isEmpty) {
      for (final t in ['vw_vendas_resumo', 'vendas', 'venda']) {
        final testSql = 'SELECT 1 FROM ${empresa.schema}.' + t + ' LIMIT 1';
        try {
          await _databaseService.executeSqlListar(sql: testSql);
          fonte = t;
          fonteSchema = empresa.schema;
          break;
        } catch (_) {}
      }
    }

    if (fonte == null || fonte.isEmpty) {
      throw Exception('Não foi possível localizar fonte de dados de vendas nos schemas ${empresa.schema} ou public.');
    }

    // 2) Detecta coluna de data preferível
    String? colunaData;
    try {
      final colSql = """
        SELECT column_name AS col
        FROM information_schema.columns
        WHERE table_schema = '$fonteSchema' AND table_name = '$fonte'
          AND column_name IN ('data','data_venda','created_at','data_fechamento','data_abertura')
        ORDER BY CASE column_name
          WHEN 'data' THEN 0
          WHEN 'data_venda' THEN 1
          WHEN 'created_at' THEN 2
          WHEN 'data_fechamento' THEN 3
          WHEN 'data_abertura' THEN 4
          ELSE 10 END
        LIMIT 1
      """;
      final colRes = await _databaseService.executeSqlListar(sql: colSql);
      if (colRes.isNotEmpty) colunaData = (colRes.first['col'] ?? '').toString();
    } catch (_) {}

    // 3) Monta consulta final
    final sql = _script.montarListagem(
      fonteSchema ?? empresa.schema,
      fonte,
      colunaData: colunaData,
      inicio: inicio,
      fim: fim,
      limit: 500,
    );

    final data = await _databaseService.executeSqlListar(sql: sql);
    return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Detalhe da venda: tenta buscar por id na tabela detectada e procura itens/pagamentos por nomes comuns
  Future<Map<String, dynamic>> buscarVendaDetalhe(dynamic id) async {
    final empresa = await empresaController.getEmpresaFromSharedPreferences();
    if (empresa == null) throw Exception('Empresa não encontrada');

    // Detecta fonte principal
    String? fonte;
    String? fonteSchema;
    final detectSql = """
      SELECT table_schema, table_name
      FROM information_schema.tables
      WHERE table_schema IN ('${empresa.schema}', 'public')
        AND (table_name IN ('vw_vendas_resumo','vendas','venda') OR table_name ILIKE '%venda%' OR table_name ILIKE '%pedido%')
      ORDER BY CASE table_name
        WHEN 'vw_vendas_resumo' THEN 0
        WHEN 'vendas' THEN 1
        WHEN 'venda' THEN 2
        ELSE 10 END, table_name
      LIMIT 1
    """;
    final r = await _databaseService.executeSqlListar(sql: detectSql);
    if (r.isNotEmpty) {
      fonteSchema = (r.first['table_schema'] ?? '').toString();
      fonte = (r.first['table_name'] ?? '').toString();
    }
    if (fonte == null || fonte.isEmpty) {
      for (final t in ['vendas', 'venda']) {
        try {
          await _databaseService.executeSqlListar(sql: 'SELECT 1 FROM ${empresa.schema}.' + t + ' LIMIT 1');
          fonte = t;
          fonteSchema = empresa.schema;
          break;
        } catch (_) {}
      }
    }
    if (fonte == null || fonte.isEmpty) throw Exception('Não foi possível localizar a tabela de vendas.');

    // Venda
    final vendaSql = 'SELECT * FROM ${fonteSchema ?? empresa.schema}.' + fonte + ' WHERE id = ' + id.toString() + ' LIMIT 1';
    final vendaRes = await _databaseService.executeSqlListar(sql: vendaSql);
    final venda = vendaRes.isNotEmpty ? Map<String, dynamic>.from(vendaRes.first) : <String, dynamic>{'id': id};

    // Itens: tenta nomes comuns
    List<Map<String, dynamic>> itens = [];
    for (final t in ['itens_venda', 'item_venda', 'venda_itens']) {
      try {
        final sql = 'SELECT * FROM ${empresa.schema}.' + t + ' WHERE id_venda = ' + id.toString() + ' ORDER BY 1';
        final res = await _databaseService.executeSqlListar(sql: sql);
        if (res.isNotEmpty) { itens = res.map((e) => Map<String, dynamic>.from(e)).toList(); break; }
      } catch (_) {}
    }

    // Pagamentos: tenta nomes comuns
    List<Map<String, dynamic>> pagamentos = [];
    for (final t in ['itens_caixa', 'caixa_itens', 'pagamentos_venda']) {
      try {
        final sql = 'SELECT * FROM ${empresa.schema}.' + t + ' WHERE id_venda = ' + id.toString() + ' ORDER BY 1';
        final res = await _databaseService.executeSqlListar(sql: sql);
        if (res.isNotEmpty) { pagamentos = res.map((e) => Map<String, dynamic>.from(e)).toList(); break; }
      } catch (_) {}
    }

    return {
      'venda': venda,
      'itens': itens,
      'pagamentos': pagamentos,
    };
  }

  // Compatível com a tela existente
  Future<Map<String, dynamic>> listarVendaDetalhe({required dynamic id}) async {
    return buscarVendaDetalhe(id);
  }

  Future<void> inserirVendaPdv({
    required Map<String, dynamic> dadosVenda,
    required List<Map<String, dynamic>> dadosVendaItens,
    required List<Map<String, dynamic>> dadosFormaPagamento,
    required List<Map<String, dynamic>> dadosMovimentacaoEstoque,
  }) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();
      String? uidUsuario = await usuarioController.getUidUsuarioFromSharedPreferences();
      final nomeDispositivo = await getDeviceName();
      // print para auditoria
      // print(nomeDispositivo);
      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      // Ajustes na venda
      dadosVenda['id_empresa'] = empresa.id;
      dadosVenda['uid_venda'] = const Uuid().v4();
      dadosVenda['uid_usuario_abriu_venda'] = uidUsuario;
      dadosVenda['uid_usuario_fechou_venda'] = uidUsuario;
      dadosVenda['id_caixa'] = 1; // TODO: Buscar id_caixa real
      dadosVenda['terminal_abertura'] = nomeDispositivo;
      dadosVenda['terminal_fechamento'] = nomeDispositivo;

      // Itens da venda
      for (var item in dadosVendaItens) {
        item['uid_usuario_lancou'] = uidUsuario;
      }

      // Itens do caixa
      for (var item in dadosFormaPagamento) {
        item['id_empresa'] = empresa.id;
        item['id_caixa'] = 1; // TODO: Buscar id_caixa real
      }

      await _databaseService.executeSqlInserirVendaPdv(
        schema: empresa.schema,
        venda: dadosVenda,
        itensVenda: dadosVendaItens,
        itensCaixa: dadosFormaPagamento,
        itensEstoque: dadosMovimentacaoEstoque,
      );
    } catch (e) {
      throw Exception('Erro ao inserir venda: $e');
    }
  }
}
