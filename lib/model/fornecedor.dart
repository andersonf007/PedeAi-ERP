// lib/model/fornecedor.dart

import 'package:pedeai/model/endereco.dart';
import 'package:pedeai/model/telefone.dart';

class Fornecedor {
  final int? id;
  final String? razaoSocial;
  final String? nomeFantasia;
  final String? cnpj;
  final String? ie;
  final String? email;
  final String? situacao_ie;
  final Endereco? endereco;
  final Telefone? telefone;

  Fornecedor({this.id, this.situacao_ie, this.razaoSocial, this.nomeFantasia, this.cnpj, this.ie, this.email, this.endereco, this.telefone});

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome_razao': razaoSocial, 'nome_popular': nomeFantasia, 'cpf_cnpj': cnpj, 'rg_ie': ie, 'telefone': telefone?.toJson(), 'email': email, 'endereco': endereco?.toJson(), 'situacao_ie': situacao_ie};
  }

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    return Fornecedor(
      id: json['id'] as int?,
      razaoSocial: json['nome_razao'] as String?,
      nomeFantasia: json['nome_popular'] as String?,
      cnpj: json['cpf_cnpj'] as String?,
      ie: json['rg_ie'] as String?,
      email: json['email'] as String?,
      situacao_ie: json['situacao_ie'] as String?,
      endereco: Endereco(
        cep: json['cep'] as String?,
        logradouro: json['logradouro'] as String?,
        numero: json['numero'] as String?,
        bairro: json['bairro'] as String?,
        cidade: json['cidade'] as String?,
        uf: json['estado'] as String?, // Atenção: 'estado' no SQL
        complemento: json['complemento'] as String?,
        pontoReferencia: json['ponto_referencia'] as String?,
        idClienteFornecedor: json['id'] as int?,
      ),
      telefone: Telefone(id: json['id'] as int?, numero: json['numero'] as String?, id_cliente_fornecedor: json['id'] as int?),
    );
  }
}
