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

  String buscarPagamentosRealizadosNoCaixa(String schema, int idCaixa) {
    return '''select 
      f.nome,
      sum(ci.valor) as valor,
      f.id,
      f.tipo_forma_pagamento_id
      from ${schema}.caixa_item ci 
      join ${schema}.venda v on v.id = ci.id_venda
      join ${schema}.caixa c on c.id = v.id_caixa
      join ${schema}.forma_pagamento f on f.id = ci.id_forma_pagamento
      where 
        v.id_caixa = $idCaixa
        and v.situacao_venda = 1
      group by 
      1,3,4''';
  }

  String buscarDadosDoCaixa(String schema, int idCaixa) {
    return '''select 
      c.id,
      c.aberto,
      c.data_abertura,
      c.data_fechamento,
      c.id_usuario_abertura,
      c.id_usuario_fechamento,
      c.valor_abertura,
      c.periodo_abertura,
      c.periodo_fechamento
      from ${schema}.caixa c
      where c.id = $idCaixa''';
  }
}
