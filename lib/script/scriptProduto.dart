class ScriptProduto{
  String listagemProdutos(String schema) {
    return """
    SELECT 
      pe.id,
      pe.created_at,
      pe.preco_custo,
      pe.preco_venda,
      pe.validade,
      pe.image_url,
      pe.produto_id_public,
      pe.id_categoria,
      pe.id_unidade,
      pe.ativo,
      p.descricao,
      p.codigo,
      e.quantidade
    FROM ${schema}.produto_empresa pe
    INNER JOIN public.produtos p ON pe.produto_id_public = p.id
    LEFT JOIN ${schema}.quantidade_estoque e ON pe.id = e.id_produto_empresa
    ORDER BY pe.id DESC
  """;
  }

  String listagemSimplesDeProdutos(String schema) {
    return """ SELECT pe.id, pe.image_url, pe.produto_id_public, pe.ativo, p.descricao, p.codigo, e.quantidade FROM ${schema}.produto_empresa pe INNER JOIN public.produtos p ON pe.produto_id_public = p.id LEFT JOIN ${schema}.quantidade_estoque e ON pe.id = e.id_produto_empresa ORDER BY pe.id DESC
  """;
  }

  String buscarDadosProdutoPorId(int produtoId, String schema) {
    return """
    SELECT 
      p.id as produto_id_public,
      p.descricao,
      p.codigo,
      pe.id,
      pe.created_at,
      pe.preco_custo,
      pe.preco_venda,
      pe.validade,
      pe.image_url,
      pe.estoque,
      pe.ativo,
      pe.id_categoria,
      pe.id_unidade,
      e.quantidade
    FROM public.produtos p
    INNER JOIN ${schema}.produto_empresa pe ON p.id = pe.produto_id_public
    LEFT JOIN ${schema}.quantidade_estoque e ON pe.id = e.id_produto_empresa
    WHERE p.id = $produtoId
    LIMIT 1
  """;
  }

  String atualizarProduto(String schema, Map<String, dynamic> dados) {
    String sql =
        """
    UPDATE public.produtos 
    SET descricao = :descricao, codigo = :codigo 
    WHERE id = :produto_id_public;
    
    UPDATE ${schema}.produto_empresa 
    SET ativo = :ativo, preco_custo = :preco_custo, preco_venda = :preco_venda, validade = :validade, image_url = :image_url, id_categoria = :id_categoria, id_unidade = :id_unidade 
    WHERE produto_id_public = :produto_id_public;
    """;

    dados.forEach((key, value) {
      if (value is String) {
        // Escapa aspas simples para evitar erro no SQL
        String safeValue = value.replaceAll("'", "''");
        sql = sql.replaceAll(':$key', "'$safeValue'");
      } else if (value == null) {
        sql = sql.replaceAll(':$key', 'NULL');
      } else {
        sql = sql.replaceAll(':$key', value.toString());
      }
    });

    return sql;
  }

}