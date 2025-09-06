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
      sum(ci.valor) as valor, -- sum(ci.troco) as valor,
      f.id,
      f.tipo_forma_pagamento_id
      from ${schema}.caixa_item ci 
      join ${schema}.venda v on v.id = ci.id_venda
      join ${schema}.forma_pagamento f on f.id = ci.id_forma_pagamento
      where 
        v.id_caixa = $idCaixa
        and v.situacao_venda = 1
        and ci.situacao = 11
      group by 
      1,3,4''';
  }

  String buscarDadosDoCaixa(String schema, int idCaixa) {
    return '''SELECT
      c.id,
      c.aberto,
      c.data_abertura,
      c.data_fechamento,
      c.id_usuario_abertura,
      c.id_usuario_fechamento,
      c.valor_abertura,
      c.periodo_abertura,
      c.periodo_fechamento,
      ua.nome AS usuario_abertura,
      uf.nome AS usuario_fechamento
    FROM
      ${schema}.caixa c
      LEFT JOIN public.usuarios ua ON ua.uid = c.id_usuario_abertura
      LEFT JOIN public.usuarios uf ON uf.uid = c.id_usuario_fechamento
    WHERE
      c.id = $idCaixa''';
  }

  String buscarReceitaDoMes(String schema) {
    return '''select 
      sum(ci.valor) as valor
      from ${schema}.caixa_item ci 
      join ${schema}.caixa c on c.id = ci.id_caixa
      WHERE 
        c.data_abertura >= date_trunc('month', NOW())
        and ci.situacao = 11''';
  }

  String buscarReceitaDoDiaDoPdv(String schema) {
    return '''SELECT
        --SUM(ci.valor) as valor, -- SUM(ci.troco) AS valor,
        sum(v.valor_total) as valor,
        count(v.id) as total_de_vendas
      FROM
        ${schema}.caixa c
        JOIN ${schema}.caixa_item ci ON c.id = ci.id_caixa
        JOIN ${schema}.venda v ON v.id = ci.id_venda
      WHERE
        c.data_abertura >= date_trunc('day', NOW())
        AND c.data_abertura < date_trunc('day', NOW()) + interval '1 day'
        AND ci.situacao = 11
        AND v.tipo_venda = 'P'
        AND v.situacao_venda = 1''';
  }

  String buscarReceitaCanceladaDoDia(String schema) {
    return '''SELECT 
        sum(ci.valor) AS valor
      FROM ${schema}.caixa_item ci 
      JOIN ${schema}.caixa c ON c.id = ci.id_caixa
      WHERE 
        c.data_abertura >= date_trunc('day', NOW())
        AND c.data_abertura < date_trunc('day', NOW()) + interval '1 day'
        AND ci.situacao = 12''';
  }

  String buscarDatasDosCaixas(String schema, String dataInicial, String dataFinal) {
    return '''SELECT
      id,
      data_abertura,
      data_fechamento
    FROM
      ${schema}.caixa
    WHERE
      data_abertura >= '$dataInicial'
      AND data_abertura <= '$dataFinal'
      --data_abertura >= date_trunc('month', NOW())
      --AND data_abertura < date_trunc('month', NOW()) + interval '1 month'
      order by id''';
  }

  String buscarReceitaDoPdvDoCaixa(String schema, int idCaixa) {
    return '''SELECT
      sum(v.valor_total) as valor,
      count(v.id) as total_de_vendas
    FROM
       ${schema}.venda v 
      join ${schema}.caixa c on c.id = v.id_caixa
    WHERE v.tipo_venda = 'P'
      AND v.situacao_venda = 1
      and v.id_caixa = $idCaixa''';
  }
}
