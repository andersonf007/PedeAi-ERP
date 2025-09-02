class FormaPagamento {
  final int id;
  final String nome;
  final String descricao;
  final bool ativo;
  final int tipoFormaPagamentoId;
  final double valor;

  FormaPagamento({required this.id, required this.nome, required this.descricao, required this.ativo, required this.tipoFormaPagamentoId, required this.valor});

  factory FormaPagamento.fromJson(Map<String, dynamic> json) {
    return FormaPagamento(id: json['id'], nome: json['nome'], descricao: json['descricao'], ativo: json['ativo'] ?? true, tipoFormaPagamentoId: json['tipo_forma_pagamento_id'] ?? 1, valor: json['valor'] ?? 0.0);
  }
}
