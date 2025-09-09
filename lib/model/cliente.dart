// lib/model/fornecedor.dart

import 'package:pedeai/model/endereco.dart';
import 'package:pedeai/model/telefone.dart';

class Cliente {
  final int? id;
  final String? nome;
  final String? nomeSocial;
  final String? dataNascimento;
  final String? cod_fidelidade;
  final String? sexo;
  final String? cpf;
  final String? ie;
  final String? email;
  final String? situacao_ie;
  final Endereco? endereco;
  final Telefone? telefone;

  Cliente({this.id, this.situacao_ie, this.nome, this.nomeSocial, this.dataNascimento, this.cod_fidelidade, this.sexo, this.cpf, this.ie, this.email, this.endereco, this.telefone});

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome_razao': nome, 'nome_popular': nomeSocial, 'cpf_cnpj': cpf, 'rg_ie': ie, 'telefone': telefone?.toJson(), 'email': email, 'endereco': endereco?.toJson(), 'situacao_ie': situacao_ie, 'data_nascimento': dataNascimento, 'cod_fidelidade': cod_fidelidade, 'sexo': sexo};
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int?,
      nome: json['nome_razao'] as String?,
      nomeSocial: json['nome_popular'] as String?,
      cpf: json['cpf_cnpj'] as String?,
      ie: json['rg_ie'] as String?,
      email: json['email'] as String?,
      situacao_ie: json['situacao_ie'] as String?,
      dataNascimento: json['data_nascimento'] as String?,
      cod_fidelidade: json['cod_fidelidade'] as String?,
      sexo: json['sexo'] as String?,
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
