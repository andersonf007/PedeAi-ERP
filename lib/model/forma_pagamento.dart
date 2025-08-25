class FormaPagamento {
  final int id;
  final String nome;
  final String descricao;
  final bool ativo;

  FormaPagamento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.ativo,
  });

  factory FormaPagamento.fromJson(Map<String, dynamic> json) {
    return FormaPagamento(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      ativo: json['ativo'] ?? true,
    );
  }
}
