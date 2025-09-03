import 'dart:io';

import 'package:pedeai/Commom/supabaseConf.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = SupabaseConfig.client;
  final SupabaseClient _adminClient = SupabaseConfig.adminClient;

  Future<List<Map<String, dynamic>>> executeSql(String sql, {Map<String, dynamic>? params, required String schema}) async {
    try {
      String finalSql = sql.replaceAll('{schema}', schema);
      final response = await _client.rpc('execute_sql', params: {'sql_query': finalSql, if (params != null) 'query_params': params});
      if (response is List) {
        if (response.isNotEmpty && response.first is int) {
          return [
            {'id': response.first},
          ];
        }
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map) {
        return [Map<String, dynamic>.from(response)];
      } else if (response == null) {
        return [];
      } else if (response.data['id'] == null) {
        return [];
      } else {
        return [
          {'id': response},
        ];
      }
    } catch (e) {
      throw Exception('Erro ao executar SQL: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> executeSql2(String sql, {Map<String, dynamic>? params, required String schema}) async {
    try {
      String finalSql = sql.replaceAll('{schema}', schema);
      final response = await _client.rpc('execute_sql2', params: {'sql_query': finalSql, if (params != null) 'query_params': params});
      if (response is List) {
        if (response.isNotEmpty && response.first is int) {
          return [
            {'id': response.first},
          ];
        }
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map) {
        return [Map<String, dynamic>.from(response)];
      } else if (response == null) {
        return [];
      } else if (response.data['id'] == null) {
        return [];
      } else {
        return [
          {'id': response},
        ];
      }
    } catch (e) {
      throw Exception('Erro ao executar SQL: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> executeSqlInserirProduto({Map<String, dynamic>? params}) async {
    try {
      final response = await _client.rpc('inserir_produto', params: params);
      if (response is List) {
        if (response.isNotEmpty && response.first is int) {
          return [
            {'id': response.first},
          ];
        }
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map) {
        return [Map<String, dynamic>.from(response)];
      } else if (response == null) {
        return [];
      } else if (response is int) {
        return [
          {'id': response},
        ];
      } else if (response.data['id'] == null) {
        return [];
      } else {
        return [
          {'id': response},
        ];
      }
    } catch (e) {
      throw Exception('Erro ao executar SQL: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> executeSqlListar({String? sql}) async {
    try {
      final response = await _adminClient.rpc('execute_sql_permissao_todal', params: {'sql_query': sql});

      if (response == null) return [];

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao executar SQL: ${e.toString()}');
    }
  }

  Future<void> executeSqlUpdate({required String sql, required String schema, Map<String, dynamic>? params}) async {
    try {
      String finalSql = sql.replaceAll('{schema}', schema);
      final response = await _client.rpc('executar_update', params: {'update_sql': finalSql});

    } catch (e) {
      throw Exception('Erro ao executar UPDATE SQL: ${e.toString()}');
    }
  }

  Future<String?> uploadImage(File file) async {
    final supabase = Supabase.instance.client;

    // Gera um nome único pro arquivo
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

    try {
      // 1. Upload da imagem para o bucket "imagens"
      await supabase.storage.from('imagens').upload(fileName, file);

      // 2. Obter a URL pública
      final publicUrl = supabase.storage.from('imagens').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> listagemSimplesDeProdutos(String schema) async {
    try {

      final response = await _client.rpc('listagem_simples_de_produtos', params: {'schema_empresa': schema});


      if (response == null) return [];

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro em listagemSimplesDeProdutos: ${e.toString()}');
    }
  }

  Future<int?> executeSqlInserirVendaPdv({required String schema, required Map<String, dynamic> venda, required List<Map<String, dynamic>> itensVenda, required List<Map<String, dynamic>> itensCaixa, required List<Map<String, dynamic>> itensEstoque}) async {
    try {
      final params = {'schema_empresa': schema, 'p_venda': venda, 'p_itens_venda': itensVenda, 'p_itens_caixa': itensCaixa, 'p_itens_estoque': itensEstoque};


      final response = await _client.rpc('inserir_venda_pdv', params: params);

      // A função retorna sempre o id_venda (BIGINT)
      if (response is int) {
        return response;
      } else if (response is Map && response.containsKey('id')) {
        return response['id'] as int;
      } else if (response is List && response.isNotEmpty) {
        return response.first['id'] as int?;
      }

      return null;
    } catch (e) {
      throw Exception('Erro ao executar SQL inserir_venda_completa: ${e.toString()}');
    }
  }

  Future<void> fecharCaixa({required String schema, required List<Map<String, dynamic>> pagamentos, required Map<String, dynamic> caixa}) async {
    try {
      final params = {'schema_empresa': schema, 'p_formas_pagamento': pagamentos, 'p_caixa': caixa};

      await _client.rpc('fechar_caixa', params: params);
    } catch (e) {
      throw Exception('Erro ao fechar caixa: ${e.toString()}');
    }
  }
  









































































































































































  //NENHUM DESSES METODOS ESTA SENDO USADO
  // Exemplo: SELECT * FROM schema.usuario;
  Future<List<Map<String, dynamic>>> selectUsuarios(String schema) async {
    const sql = 'SELECT * FROM {schema}.usuario;';
    return await executeSql(sql, schema: schema);
  }

  // Exemplo: INSERT INTO schema.usuario (nome, email) VALUES ('João', 'joao@email.com');
  Future<void> insertUsuario({required String schema, required String nome, required String email}) async {
    final sql = '''
      INSERT INTO {schema}.usuario (nome, email)
      VALUES (:nome, :email);
    ''';
    await executeSql(sql, schema: schema, params: {'nome': nome, 'email': email});
  }

  // Exemplo: UPDATE schema.usuario SET nome = 'Novo Nome' WHERE id = 1;
  Future<void> updateUsuario({required String schema, required int id, required String nome}) async {
    final sql = '''
      UPDATE {schema}.usuario
      SET nome = :nome
      WHERE id = :id;
    ''';
    await executeSql(sql, schema: schema, params: {'id': id, 'nome': nome});
  }

  // Exemplo: DELETE FROM schema.usuario WHERE id = 1;
  Future<void> deleteUsuario({required String schema, required int id}) async {
    final sql = '''
      DELETE FROM {schema}.usuario
      WHERE id = :id;
    ''';
    await executeSql(sql, schema: schema, params: {'id': id});
  }

  /** Métodos para manipulação de dados

String
params: {
  'nome': 'João',
}

int / double
params: {
  'idade': 30,
  'altura': 1.75,
}

bool
params: {
  'ativo': true,
}

DateTime
params: {
  'data_nascimento': DateTime(2020, 05, 01).toIso8601String(),
}

List (Array)
params: {
  'tags': ['tecnologia', 'negócios', 'vendas'],
}

Map (JSON)
params: {
  'detalhes': {
    'peso': 3.5,
    'dimensoes': {'largura': 20, 'altura': 30}
  }
}

XML
params: {
  'dados_xml': '''<cliente><nome>João</nome></cliente>''',
}

EXEMPLO DE USO:

Future<void> insertPedido({
  required String schema,
}) async {
  final sql = '''
    INSERT INTO {schema}.pedido (
      cliente_nome,
      valor_total,
      pago,
      data_pedido,
      produtos,
      endereco_entrega,
      dados_fiscais_xml
    )
    VALUES (
      :cliente_nome,
      :valor_total,
      :pago,
      :data_pedido,
      :produtos,
      :endereco_entrega,
      xmlparse(content :dados_fiscais_xml)
    );
  ''';

  await executeSql(
    sql,
    schema: schema,
    params: {
      'cliente_nome': 'João da Silva',
      'valor_total': 159.90,
      'pago': true,
      'data_pedido': DateTime.now().toIso8601String(),
      'produtos': ['camiseta', 'calça', 'tênis'],
      'endereco_entrega': {
        'rua': 'Av. Brasil',
        'numero': 123,
        'cidade': 'São Paulo',
        'estado': 'SP'
      },
      'dados_fiscais_xml': '<nfe><valor>159.90</valor></nfe>',
    },
  );
}


 */
}
