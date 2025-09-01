class ScriptCaixa {
  String inserirCaixa(String schema, Map<String, dynamic> dados) {
    return '''
      INSERT INTO ${schema}.caixa (aberto, data_abertura, id_usuario_abertura, valor_abertura, periodo_abertura)
      VALUES (${dados['aberto']}, '${dados['data_abertura']}', ${dados['id_usuario_abertura']}, ${dados['valor_abertura']}, '${dados['periodo_abertura']}')
      returning id;
    ''';
  }

  String buscarCaixaAberto(String schema) {
    return '''select id from ${schema}.caixa where aberto = true ''';
  }
}
