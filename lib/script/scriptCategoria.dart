class ScriptCategoria{
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

}