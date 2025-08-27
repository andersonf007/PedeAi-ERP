class ScriptFormaPagamento {
  String inserirFormaPagamento(String schema, Map<String, dynamic> dados) {
    return '''
      INSERT INTO ${schema}.forma_pagamento (nome, descricao, tipo_forma_pagamento_id)
      VALUES ('${dados['nome']}', '${dados['descricao']}', ${dados['tipo_forma_pagamento_id']}) returning id;
    ''';
  }

  String buscarFormaPagamentoPorId(int id, String schema) {
    return "select * from ${schema}.forma_pagamento where id = $id";
  }

  String buscarListaFormaPagamentos(String schema) {
    return "select * from ${schema}.forma_pagamento";
  }

  String atualizarFormaPagamento(String schema, Map<String, dynamic> dados) {
    final id = dados['id'];
    final nome = dados['nome'];
    final descricao = dados['descricao'];
    final tipoId = dados['tipo_forma_pagamento_id'];
    return '''
      UPDATE ${schema}.forma_pagamento
      SET nome = '$nome', descricao = '$descricao', tipo_forma_pagamento_id = $tipoId
      WHERE id = $id returning id;
    ''';
  }

  String atualizarStatusFormaPagamento(String schema, Map<String, dynamic> dados) {
    final id = dados['id'];
    final ativo = dados['ativo'];
    return '''
      UPDATE ${schema}.forma_pagamento
      SET ativo = ${ativo == null ? 'ativo' : (ativo ? 'true' : 'false')}
      WHERE id = $id returning id;
    ''';
  }

  String buscarListaFormaPagamentosAtivas(String schema) {
    return "select * from ${schema}.forma_pagamento where ativo = true order by tipo_forma_pagamento_id";
  }
}
