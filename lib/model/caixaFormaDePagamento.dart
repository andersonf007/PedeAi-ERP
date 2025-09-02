class CaixaFormaDePagamento {
  final int id;
  final int idCaixa;
  final int idFormaPagamento;
  final double valor;
  final int tipo_forma_pagamento_id;

  CaixaFormaDePagamento({required this.id, required this.idCaixa, required this.idFormaPagamento, required this.valor, required this.tipo_forma_pagamento_id});

  factory CaixaFormaDePagamento.fromJson(Map<String, dynamic> json) {
    return CaixaFormaDePagamento(id: json['id'], idCaixa: json['id_caixa'], idFormaPagamento: json['id_forma_de_pagamento'], valor: json['valor'], tipo_forma_pagamento_id: json['tipo_forma_pagamento_id']);
  }
}
