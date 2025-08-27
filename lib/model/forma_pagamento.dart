class FormaPagamento {
  final int id;
  final String nome;
  final String descricao;
  final bool ativo;
  final int tipoFormaPagamentoId;

  FormaPagamento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.ativo,
    required this.tipoFormaPagamentoId,
  });

  factory FormaPagamento.fromJson(Map<String, dynamic> json) {
    return FormaPagamento(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      ativo: json['ativo'] ?? true,
      tipoFormaPagamentoId: json['tipo_forma_pagamento_id'] ?? 1,
    );
  }
}
