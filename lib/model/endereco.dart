class Endereco{
  final int? idClienteFornecedor;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? pontoReferencia;
  final String? complemento;

  Endereco({
    this.cep,
    this.logradouro,
    this.numero,
    this.bairro,
    this.cidade,
    this.uf,
    this.pontoReferencia,
    this.complemento,
this.idClienteFornecedor,
  });

Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': uf,
      'ponto_referencia': pontoReferencia,
      'complemento': complemento,
      'id_cliente_fornecedor': idClienteFornecedor,
    };
  }

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      uf: json['estado'] as String?,
      pontoReferencia: json['ponto_referencia'] as String?,
      complemento: json['complemento'] as String?,
      idClienteFornecedor: json['id_cliente_fornecedor'] as int?,
    );
  }
}