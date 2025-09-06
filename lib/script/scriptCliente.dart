// lib/script/scriptFornecedor.dart

class ScriptCliente {
  String buscarListaClientes(String schema) {
    return '''select
        cf.id,
        cf.nome_razao,
        cf.nome_popular,
        cf.cpf_cnpj
      from cliente_fornecedor cf
      join $schema.cliente_empresa ce on cf.id = ce.id_cliente_public
      where cf.fornecedor = false
      order by cf.nome_popular''';
  }

  String buscarClientePorId(int id) {
    return '''SELECT cf.id,
      cf.nome_razao,
      cf.nome_popular,
      cf.cpf_cnpj,
      cf.rg_ie,
      cf.situacao_ie,
      cf.email,
      cf.data_nascimento,
      cf.cod_fidelidade,
      cf.sexo,
      e.cep,
      e.logradouro,
      e.numero,
      e.bairro,
      e.cidade,
      e.estado,
      e.ponto_referencia,
      e.complemento,
      t.numero
      FROM cliente_fornecedor cf
      JOIN endereco e on e.id_cliente_fornecedor = cf.id
      join telefone t on t.id_cliente_fornecedor = cf.id
      WHERE cf.id = $id ''';
  }

  String scriptAtualizarCliente(Map<String, dynamic> dados) {
    return """
    UPDATE public.cliente_fornecedor
    SET
      nome_razao = '${dados['nome_razao']}',
      email = '${dados['email']}',
      cpf_cnpj = '${dados['cpf_cnpj']}',
      rg_ie = '${dados['rg_ie']}',
      tipo_pessoa = '${dados['tipo_pessoa']}',
      situacao_ie = '${dados['situacao_ie']}',
      fornecedor = ${dados['fornecedor'] ? 'true' : 'false'},
      nome_popular = '${dados['nome_popular']}',
      data_nascimento = '${dados['data_nascimento']}',
      cod_fidelidade = '${dados['cod_fidelidade']}',
      sexo = '${dados['sexo']}'
    WHERE id = ${dados['id']};

    UPDATE public.endereco
    SET
      cep = '${dados['cep']}',
      logradouro = '${dados['logradouro']}',
      numero = '${dados['numero']}',
      complemento = '${dados['complemento']}',
      ponto_referencia = '${dados['ponto_referencia']}',
      cidade = '${dados['cidade']}',
      estado = '${dados['estado']}',
      bairro = '${dados['bairro']}'
    WHERE id_cliente_fornecedor = ${dados['id']};

    UPDATE public.telefone
    SET
      numero = '${dados['numero']}'
    WHERE id_cliente_fornecedor = ${dados['id']} returning ${dados['id']};
  """;
  }

  String scriptVerificarClienteJaEstaCadastrado(String cpf) {
    return '''SELECT id FROM cliente_fornecedor WHERE cpf_cnpj = '$cpf' ''';
  }

  String scriptVerificarClienteJaEstaVinculadoNaEmpresa(String schema, int id) {
    return '''SELECT id FROM $schema.cliente_empresa WHERE id_cliente_public = $id ''';
  }

  String scriptInserirIdClienteNaEmpresa(String schema, int idCliente) {
    return '''INSERT INTO $schema.cliente_empresa (id_cliente_public) VALUES ($idCliente) returning id''';
  }
}
