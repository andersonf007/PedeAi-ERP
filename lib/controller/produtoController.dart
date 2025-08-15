import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/script/script.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/model/produto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Produtocontroller {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final Script script = Script();
  late SharedPreferences prefs;

  Future<void> inserirProdutoComPreco(Map<String, dynamic> dados) async {
    await _databaseService.executeSqlInserirProduto(params: {'descricao': dados['descricao'], 'codigo': dados['codigo'], 'preco': dados['preco'], 'estoque': dados['estoque'], 'schema_empresa': dados['schema_empresa']});
  }

  // Buscar dados da empresa no SharedPreferences
  Future<Empresa?> _getEmpresaFromSharedPreferences() async {
    try {
      prefs = await SharedPreferences.getInstance();
      String? empresaJson = prefs.getString('empresa');

      if (empresaJson != null) {
        Map<String, dynamic> empresaMap = json.decode(empresaJson);
        return Empresa.fromJson(empresaMap);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar empresa do SharedPreferences: $e');
      return null;
    }
  }

  // Listar todos os produtos da empresa
  Future<List<Produto>> listarProdutos() async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await _getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      // Query para buscar produtos com JOIN entre as tabelas
      String query = script.listagemProdutos(empresa.schema);
      // Executar query
      final response = await _databaseService.executeSqlListar(sql: query);

      if (response.isEmpty) {
        return [];
      }

      // Converter resposta para lista de produtos
      List<Produto> produtos = response.map<Produto>((item) {
        return Produto.fromJson({'id': item['id'], 'created_at': item['created_at'], 'preco': item['preco'], 'estoque': item['estoque'], 'produto_id_public': item['produto_id_public'], 'descricao': item['descricao'], 'codigo': item['codigo']});
      }).toList();

      return produtos;
    } catch (e) {
      print('Erro ao listar produtos: $e');
      return [];
    }
  }

  // Adicione este método na classe Produtocontroller

  Future<Produto?> buscarProdutoPorId(int produtoId) async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await _getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      // Query para buscar produto específico
      String query = script.buscarDadosProdutoPorId(produtoId, empresa.schema);

      // Executar query
      final response = await _databaseService.executeSql2(query, schema: empresa.schema);

      if (response.isEmpty) {
        return null;
      }

      // Converter resposta para Produto
      final item = response.first;
      Produto produto = Produto.fromJson({'id': item['id'], 'created_at': item['created_at'], 'preco': item['preco'], 'estoque': item['estoque'], 'produto_id_public': item['produto_id_public'], 'descricao': item['descricao'], 'codigo': item['codigo']});

      return produto;
    } catch (e) {
      print('Erro ao buscar produto por ID: $e');
      return null;
    }
  }

  // Adicione este método na classe Produtocontroller

  Future<void> atualizarProduto(Map<String, dynamic> dados) async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await _getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      // Query para atualizar produto
      String query = script.atualizarProduto(empresa.schema).replaceAll(':descricao', "'${dados['descricao']}'").replaceAll(':codigo', "'${dados['codigo']}'").replaceAll(':preco', dados['preco'].toString()).replaceAll(':estoque', dados['estoque'].toString()).replaceAll(':produto_id_public', dados['produto_id_public'].toString());

      // Executar query de update
      await _databaseService.executeSqlUpdate(sql: query, schema: empresa.schema);

      print('Produto atualizado com sucesso!');
    } catch (e) {
      print('Erro ao atualizar produto: $e');
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  /*
  // Buscar produtos com filtro de pesquisa
  Future<List<Produto>> buscarProdutos(String termoBusca) async {
    try {
      Empresa? empresa = await _getEmpresaFromSharedPreferences();
      
      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      String query = '''
        SELECT 
          pe.id,
          pe.created_at,
          pe.preco,
          pe.estoque,
          pe.produto_id_public,
          p.descricao,
          p.codigo
        FROM ${empresa.schema}.produto_empresa pe
        INNER JOIN public.produtos p ON pe.produto_id_public = p.id
        WHERE LOWER(p.descricao) LIKE LOWER('%$termoBusca%') 
           OR LOWER(p.codigo) LIKE LOWER('%$termoBusca%')
        ORDER BY pe.created_at DESC
      ''';

      final response = await _databaseService.executeQuery(query);
      
      if (response.isEmpty) {
        return [];
      }

      List<Produto> produtos = response.map<Produto>((item) {
        return Produto.fromJson({
          'id': item['id'],
          'created_at': item['created_at'],
          'preco': item['preco'],
          'estoque': item['estoque'],
          'produto_id_public': item['produto_id_public'],
          'descricao': item['descricao'],
          'codigo': item['codigo'],
        });
      }).toList();

      return produtos;

    } catch (e) {
      print('Erro ao buscar produtos: $e');
      return [];
    }
  }

  // Filtrar produtos por status de estoque
  Future<List<Produto>> filtrarProdutosPorStatus(String filtro) async {

    List<Produto> todosProdutos = await listarProdutos();
    
    switch (filtro) {
      case 'Ativos':
        return todosProdutos.where((produto) => produto.estoque > 0).toList();
      case 'Inativos':
        return todosProdutos.where((produto) => produto.estoque == 0).toList();
      case 'Todos':
      default:
        return todosProdutos;
    }
  }*/
}
