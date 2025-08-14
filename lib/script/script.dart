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
}
