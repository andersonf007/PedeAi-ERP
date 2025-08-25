class ScriptUnidade {


  String deletarUnidade(String schema, int id) {
    return "DELETE FROM ${schema}.unidade WHERE id = $id;";
  }

  String inserirUnidade(String schema, Map<String, dynamic> dados) {
    return '''
      INSERT INTO ${schema}.unidade (nome, sigla)
      VALUES ('${dados['nome']}', '${dados['sigla']}') returning id;
    ''';
  }

  String buscarUnidadePorId(int id, String schema) {
    return "select * from ${schema}.unidade where id = $id";
  }

  String buscarListaUnidades(String schema) {
    return "select * from ${schema}.unidade";
  }

  String atualizarUnidade(String schema, Map<String, dynamic> dados) {
    final id = dados['id'];
    final nome = dados['nome'];
    final sigla = dados['sigla'];
    return '''
      UPDATE ${schema}.unidade
      SET nome = '$nome', sigla = '$sigla'
      WHERE id = $id returning id;
    ''';
  }

  String atualizarStatusUnidade(String schema, Map<String, dynamic> dados) {
    final id = dados['id'];
    final ativo = dados['ativo'];
    return '''
      UPDATE ${schema}.unidade
      SET ativo = ${ativo == null ? 'ativo' : (ativo ? 'true' : 'false')}
      WHERE id = $id returning id;
    ''';
  }

}
