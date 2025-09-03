// lib/model/fornecedor.dart

class Fornecedor {
  final int? id;
  final String razaoSocial;
  final String? nomeFantasia;
  final String? cnpj;
  final String? ie; // Inscrição Estadual
  final String? telefone;
  final String? email;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? uf;

  Fornecedor({
    this.id,
    required this.razaoSocial,
    this.nomeFantasia,
    this.cnpj,
    this.ie,
    this.telefone,
    this.email,
    this.cep,
    this.logradouro,
    this.numero,
    this.bairro,
    this.cidade,
    this.uf,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'razao_social': razaoSocial,
      'nome_fantasia': nomeFantasia,
      'cnpj': cnpj,
      'ie': ie,
      'telefone': telefone,
      'email': email,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
    };
  }

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    return Fornecedor(
      id: json['id'] as int?,
      razaoSocial: (json['razao_social'] ?? '') as String,
      nomeFantasia: json['nome_fantasia'] as String?,
      cnpj: json['cnpj'] as String?,
      ie: json['ie'] as String?,
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      uf: json['uf'] as String?,
    );
  }
}
