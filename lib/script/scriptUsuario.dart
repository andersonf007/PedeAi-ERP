class ScriptUsuario {
  String listarUsuarios(int idEmpresa) {
    return """
select pu.nome,pu.email, pe.ativo, pe.uid_usuario, pe.id_empresa
from public.usuarios pu join usuarios_empresas pe on pu.uid = pe.uid_usuario
where pe.id_empresa = $idEmpresa
""";
  }

  String scriptInsertUsuario(Map<String, dynamic> dados) {
    return '''
    INSERT INTO public.usuarios (nome, email, uid)
    VALUES (
      '${dados['nome']}',
      '${dados['email']}',
      '${dados['uid']}'
    ) RETURNING id;''';
  }

  String scriptInsertUsuarioDaEmpresa(Map<String, dynamic> dados) {
    return '''
    INSERT INTO public.usuarios_empresas (uid_usuario, id_empresa)
    VALUES (
      '${dados['uid']}',
      '${dados['id_empresa']}'
    ) RETURNING id;''';
  }

  String scriptAtualizarUsuario(Map<String, dynamic> dados) {
    return """
      UPDATE public.usuarios
      SET nome = '${dados['nome']}'
      WHERE uid = '${dados['uid']}';
      UPDATE public.usuarios_empresas
      SET ativo = ${dados['ativo'] ? 'true' : 'false'}
      WHERE uid_usuario = '${dados['uid']}' returning id;
    """;
  }
}
