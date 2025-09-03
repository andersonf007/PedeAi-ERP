class ScriptVenda {
  String buscarVendas(String schema, String datainicial, String datafinal) {
    return """
      SELECT 
        v.id,
        v.data_abertura,
        v.valor_total,
        v.tipo_venda,
        v.id_caixa,
        --v.id_cliente,
        --c.nome,
        s.descricao
      FROM $schema.venda v 
      JOIN $schema.caixa c ON c.id = v.id_caixa
      JOIN public.situacao_venda s ON s.id = v.situacao_venda
      --LEFT JOIN public.cliente c ON c.id = v.id_cliente
      WHERE c.data_abertura BETWEEN '$datainicial 00:00:00' AND '$datafinal 23:59:59'
      ORDER BY v.data_abertura DESC
    """;
  }

  String buscarItensDaVenda(String schema, int idVenda) {
    return """
      SELECT 
        s.descricao as situacao,
        vi.quantidade,
        vi.preco_unitario,
        vi.preco_total,
        p.descricao
      FROM $schema.venda v 
      JOIN $schema.venda_item vi on vi.id_venda = v.id
      join public.produtos p on p.id = vi.id_produto
      JOIN public.situacao_venda s ON s.id = v.situacao_venda
      WHERE 
        v.id = $idVenda
        AND vi.situacao = 10
    """;
  }

String buscarFormasDePagamentoDaVenda(String schema, int idVenda) {
  return """
    SELECT 
      ci.valor,
      ci.troco,
      f.nome
    FROM $schema.venda v 
    LEFT JOIN $schema.caixa_item ci on v.id = ci.id_venda
    left join $schema.forma_pagamento f on f.id = ci.id_forma_pagamento
    JOIN public.situacao_venda s ON s.id = v.situacao_venda
    --LEFT JOIN public.cliente c ON c.id = v.id_cliente
    WHERE 
      v.id = $idVenda
  """;
}

String buscarDadosDaVenda(String schema, int idVenda) {
  return """
    SELECT 
      v.id,
      v.data_abertura,
      v.valor_total,
      v.tipo_venda,
      v.id_caixa,
      v.desconto,
      v.acrescimo,
      s.descricao as situacao,
      v.cpf_cliente,
      c.aberto
    FROM $schema.venda v 
    JOIN $schema.caixa c ON c.id = v.id_caixa
    JOIN public.situacao_venda s ON s.id = v.situacao_venda
    --LEFT JOIN public.cliente c ON c.id = v.id_cliente
    WHERE 
      v.id = $idVenda
  """;
}
}
