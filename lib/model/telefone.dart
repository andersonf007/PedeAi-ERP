class Telefone {
  int? id;
  String? numero;
  int? id_cliente_fornecedor;

  Telefone({this.id, this.numero, this.id_cliente_fornecedor});

  Map<String, dynamic> toJson() {
    return {'id': id, 'numero': numero, 'id_cliente_fornecedor': id_cliente_fornecedor};
  }

factory Telefone.fromJson(Map<String, dynamic> json) {
    return Telefone(
      id: json['id'],
      numero: json['numero'],
      id_cliente_fornecedor: json['id_cliente_fornecedor'],
    );
  }
}
