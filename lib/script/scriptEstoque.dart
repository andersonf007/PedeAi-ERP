class ScriptEstoque {
  String inserirQuantidadeEstoque(String schema, Map<String, dynamic> dados) {
    return '''
      INSERT INTO ${schema}.quantidade_estoque (id_produto_empresa, quantidade, id_empresa)
      VALUES ('${dados['id_produto_empresa']}', '${dados['quantidade']}', '${dados['id_empresa']}') returning id;
    ''';
  }

  String inserirMovimentacaoEstoque(String schema, Map<String, dynamic> dados) {
  if (dados['id_venda'] != null) {
    return '''
      INSERT INTO $schema.movimento_estoque 
      (id_venda, id_produto_empresa, quantidade, tipo_movimento, uid_usuario)
      VALUES (
        '${dados['id_venda']}',
        '${dados['id_produto_empresa']}',
        '${dados['quantidade']}',
        '${dados['tipo_movimento']}',
        '${dados['uid_usuario']}'
      ) 
      RETURNING id;
    ''';
  } else {
    return '''
      INSERT INTO $schema.movimento_estoque 
      (id_produto_empresa, quantidade, tipo_movimento, uid_usuario)
      VALUES (
        '${dados['id_produto_empresa']}',
        '${dados['quantidade']}',
        '${dados['tipo_movimento']}',
        '${dados['uid_usuario']}'
      ) 
      RETURNING id;
    ''';
  }
  }

  String scriptAtualizarQuantidade(String schema,Map<String, dynamic> dados) {
    return '''
      UPDATE ${schema}.quantidade_estoque
      SET quantidade = '${dados['quantidade']}'
      WHERE id_produto_empresa = '${dados['id_produto_empresa']}';
    ''';
  }
}
