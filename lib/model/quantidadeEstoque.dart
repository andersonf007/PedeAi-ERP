class QuantidadeEstoque {
  final int id;
  final double quantidade;
  final int id_produto_empresa;
  final int id_empresa;

  QuantidadeEstoque({
    required this.id,
    required this.quantidade,
    required this.id_produto_empresa,
    required this.id_empresa,
  });

Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantidade': quantidade,
      'id_produto_empresa': id_produto_empresa,
      'id_empresa': id_empresa,
    };
  }

  factory QuantidadeEstoque.fromMap(Map<String, dynamic> map) {
    return QuantidadeEstoque(
      id: map['id'],
      quantidade: map['quantidade'],
      id_produto_empresa: map['id_produto_empresa'],
      id_empresa: map['id_empresa'],
    );
  }
}
