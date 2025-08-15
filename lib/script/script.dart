class Script {
  String buscarIdDasEmpresasDoUsuario(String uid) {
    // Use alias para evitar conflito com palavra reservada
    return 'select id_empresa from public.usuarios_empresas where uid_usuario = \'$uid\'';
  }

  String buscarNomeFantasiaDasEmpresasDoUsuario(int id) {
    return "select id,fantasia from public.empresas where id = $id";
  }

  String buscarDadosDaEmpresa(int id) {
    return "select * from public.empresas where id = $id";
  }

  String inserirProduto(Map<String, dynamic> dados) {
    return """

""";
  }

  String listagemProdutos(String schema) {
    return """
    SELECT 
      pe.id,
      pe.created_at,
      pe.preco,
      pe.estoque,
      pe.produto_id_public,
      p.descricao,
      p.codigo
    FROM ${schema}.produto_empresa pe
    INNER JOIN public.produtos p ON pe.produto_id_public = p.id
    ORDER BY pe.id DESC
  """;
  }

// Adicione este método na classe Script

String buscarDadosProdutoPorId(int produtoId, String schema) {
  return """
    SELECT 
      p.id as produto_id_public,
      p.descricao,
      p.codigo,
      pe.id,
      pe.created_at,
      pe.preco,
      pe.estoque
    FROM public.produtos p
    INNER JOIN ${schema}.produto_empresa pe ON p.id = pe.produto_id_public
    WHERE p.id = $produtoId
    LIMIT 1
  """;
}

String atualizarProduto(String schema) {
  return """
    UPDATE public.produtos 
    SET descricao = :descricao, codigo = :codigo 
    WHERE id = :produto_id_public;
    
    UPDATE ${schema}.produto_empresa 
    SET preco = :preco, estoque = :estoque 
    WHERE produto_id_public = :produto_id_public;
  """;
}
}
