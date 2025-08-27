class TipoFormaPagamento {
  final int id;
  final String nome;

  TipoFormaPagamento(this.id, this.nome);

  static List<TipoFormaPagamento> tipos = [
    TipoFormaPagamento(1, 'Dinheiro'),
    TipoFormaPagamento(11, 'Pix'),
    TipoFormaPagamento(2, 'Cheque'),
    TipoFormaPagamento(3, 'Cartão de crédito'),
    TipoFormaPagamento(4, 'Cartão de débito'),
    TipoFormaPagamento(5, 'Crédito loja'),
    TipoFormaPagamento(6, 'Vale alimentação'),
    TipoFormaPagamento(7, 'Vale refeição'),
    TipoFormaPagamento(8, 'Vale presente'),
    TipoFormaPagamento(9, 'Vale combustível'),
    TipoFormaPagamento(10, 'Outros'),
  ];
}