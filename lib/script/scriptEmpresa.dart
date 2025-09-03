class ScriptEmpresa {

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

String atualizarDadosEmpresa(Map<String, dynamic> empresa) {
  return '''
    UPDATE public.empresas SET
      cnpj = '${empresa['cnpj']}',
      razao = '${empresa['razao']}',
      fantasia = '${empresa['fantasia']}',
      cep = '${empresa['cep']}',
      logradouro = '${empresa['logradouro']}',
      numero = '${empresa['numero']}',
      bairro = '${empresa['bairro']}',
      municipio = '${empresa['municipio']}',
      uf = '${empresa['uf']}',
      telefone = '${empresa['telefone']}',
      email = '${empresa['email']}'
    WHERE id = ${empresa['id']} RETURNING id;
  ''';
}
}
