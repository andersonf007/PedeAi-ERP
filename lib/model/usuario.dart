class Usuario {
  final String uid;
  final int id_empresa;
  final bool ativo;
  final String nome;
  final String email;

Usuario({
  required this.uid,
  required this.id_empresa,
  required this.ativo,
  required this.nome,
  required this.email,
});

Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'id_empresa': id_empresa,
      'ativo': ativo,
      'nome': nome,
      'email': email,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      uid: json['uid_usuario'] ?? '',
      id_empresa: json['id_empresa']?.toInt() ?? 0,
      ativo: json['ativo'] ?? true,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Método para formatar o nome
  String get nomeFormatado => nome.isNotEmpty ? nome : 'Usuário sem nome';
}
