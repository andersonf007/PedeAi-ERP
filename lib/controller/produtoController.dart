import 'dart:io';

import 'package:pedeai/controller/authService.dart';
import 'package:pedeai/controller/databaseService.dart';
import 'package:pedeai/controller/empresaController.dart';
import 'package:pedeai/model/empresa.dart';
import 'package:pedeai/model/produto.dart';
import 'package:pedeai/script/scriptProduto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Produtocontroller {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final ScriptProduto script = ScriptProduto();
  late SharedPreferences prefs;
  final EmpresaController empresaController = EmpresaController();

  Future<int> inserirProduto(Map<String, dynamic> dados) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }
      dados['schema_empresa'] = empresa.schema;
      final resultado = await _databaseService.executeSqlInserirProduto(params: dados);
      return resultado.first['id'] as int;
    } catch (e) {
      throw Exception('Erro ao inserir produto: $e');
    }
  }

  Future<List<Produto>> listarProdutos() async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      String query = script.listagemProdutos(empresa.schema);
      // Executar query
      final response = await _databaseService.executeSql2( query, schema: empresa.schema);

      if (response.isEmpty) {
        return [];
      }

      // Converter resposta para lista de produtos
      List<Produto> produtos = response.map<Produto>((item) {
        return Produto.fromJson(item);
      }).toList();

      return produtos;
    } catch (e) {
      return [];
    }
  }

  Future<List<Produto>> listagemSimplesDeProdutos() async {
    try {
      // Buscar dados da empresa
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      // Executar query
      final response = await _databaseService.listagemSimplesDeProdutos(empresa.schema);

      if (response.isEmpty) {
        return [];
      }

      // Converter resposta para lista de produtos
      List<Produto> produtos = response.map<Produto>((item) {
        return Produto.fromJson(item);
      }).toList();

      return produtos;
    } catch (e) {
      return [];
    }
  }

  Future<Produto?> buscarProdutoPorId(int produtoId) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      String query = script.buscarDadosProdutoPorId(produtoId, empresa.schema);

      final response = await _databaseService.executeSql2(query, schema: empresa.schema);

      if (response.isEmpty) {
        return null;
      }

      Produto produto = Produto.fromJson(response.first);

      return produto;
    } catch (e) {
      return null;
    }
  }

  Future<void> atualizarProduto(Map<String, dynamic> dados) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      if (!dados.containsKey('produto_id_public') || dados['produto_id_public'] == null) {
        throw Exception('ID do produto é obrigatório para atualização');
      }

      String query = script.atualizarProduto(empresa.schema, dados);

      await _databaseService.executeSqlUpdate(sql: query, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  Future<void> atualizarStatusProduto(Map<String, dynamic> dados) async {
    try {
      Empresa? empresa = await empresaController.getEmpresaFromSharedPreferences();

      if (empresa == null) {
        throw Exception('Dados da empresa não encontrados');
      }

      if (!dados.containsKey('produto_id_public') || dados['produto_id_public'] == null) {
        throw Exception('ID do produto é obrigatório para atualização');
      }

      String query = script.atualizarStatusProduto(empresa.schema, dados);

      await _databaseService.executeSqlUpdate(sql: query, schema: empresa.schema);
    } catch (e) {
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      return await _databaseService.uploadImage(file);
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
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
