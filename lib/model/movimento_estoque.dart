class MovimentoEstoque {
  final int id;
  final int id_venda;
  final int id_produto_empresa;
  final double quantidade;
  final String motivo;
  final String tipo_movimento;
  final String uid_usuario;
  final String data;
  final String created_at;

  MovimentoEstoque({
    required this.id,
    required this.id_venda,
    required this.id_produto_empresa,
    required this.quantidade,
    required this.motivo,
    required this.tipo_movimento,
    required this.uid_usuario,
    required this.data,
    required this.created_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_venda': id_venda,
      'id_produto_empresa': id_produto_empresa,
      'motivo': motivo,
      'quantidade': quantidade,
      'tipo_movimento': tipo_movimento,
      'uid_usuario': uid_usuario,
      'data': data,
      'created_at': created_at,
    };
  }

  factory MovimentoEstoque.fromMap(Map<String, dynamic> map) {
    return MovimentoEstoque(
      id: map['id'],
      id_venda: map['id_venda'],
      id_produto_empresa: map['id_produto_empresa'],
      quantidade: map['quantidade'],
      motivo: map['motivo'],
      tipo_movimento: map['tipo_movimento'],
      uid_usuario: map['uid_usuario'],
      data: map['data'],
      created_at: map['created_at'],
    );
  }
}
