class ScriptCategoria {
  String inserirCategoria(String schema, Map<String, dynamic> dados) {
    return '''
      INSERT INTO ${schema}.categoria (nome, descricao)
      VALUES ('${dados['nome']}', '${dados['descricao']}') returning id;
    ''';
  }

  String buscarCategoriaPorId(int id, String schema) {
    return "select * from ${schema}.categoria where id = $id";
  }

  String buscarListaCategorias(String schema) {
    return "select * from ${schema}.categoria";
  }

  String atualizarCategoria(String schema, Map<String, dynamic> dados) {
    final id = dados['id'];
    final nome = dados['nome'];
    final descricao = dados['descricao'];
    return '''
      UPDATE ${schema}.categoria
      SET nome = '$nome', descricao = '$descricao'
      WHERE id = $id returning id;
    ''';
  }

  String atualizarStatusCategoria(String schema, Map<String, dynamic> dados) {
    final id = dados['id'];
    final ativo = dados['ativo'];
    return '''
      UPDATE ${schema}.categoria
      SET ativo = ${ativo == null ? 'ativo' : (ativo ? 'true' : 'false')}
      WHERE id = $id returning id;
    ''';
  }
}
