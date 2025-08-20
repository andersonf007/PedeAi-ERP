class ScriptUnidade {

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

}
