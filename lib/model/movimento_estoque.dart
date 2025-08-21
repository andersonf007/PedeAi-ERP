class MovimentoEstoque {
  final int id;
  final int id_venda;
  final int id_produto_empresa;
  final double quantidade;
  final String tipo_movimento;
  final String uid_usuario;
  final String data;

  MovimentoEstoque({
    required this.id,
    required this.id_venda,
    required this.id_produto_empresa,
    required this.quantidade,
    required this.tipo_movimento,
    required this.uid_usuario,
    required this.data,
  });

Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_venda': id_venda,
      'id_produto_empresa': id_produto_empresa,
      'quantidade': quantidade,
      'tipo_movimento': tipo_movimento,
      'uid_usuario': uid_usuario,
      'data': data,
    };
  }

  factory MovimentoEstoque.fromMap(Map<String, dynamic> map) {
    return MovimentoEstoque(
      id: map['id'],
      id_venda: map['id_venda'],
      id_produto_empresa: map['id_produto_empresa'],
      quantidade: map['quantidade'],
      tipo_movimento: map['tipo_movimento'],
      uid_usuario: map['uid_usuario'],
      data: map['data'],
    );
  }
}
