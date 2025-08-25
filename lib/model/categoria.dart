class Categoria {
  final int id;
  final String nome;
  final String descricao;
  final bool ativo;

  Categoria({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.ativo,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      ativo: json['ativo'] ?? true,
    );
  }
}
