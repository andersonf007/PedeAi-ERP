class Empresa {
  final int id;
  final String cnpj;
  final String razao;
  final String fantasia;
  final String cep;
  final String logradouro;
  final String numero;
  final String bairro;
  final String municipio;
  final String uf;
  final String telefone;
  final String email;
  final String schema;

  Empresa({
    required this.id,
    required this.cnpj,
    required this.razao,
    required this.fantasia,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.municipio,
    required this.uf,
    required this.telefone,
    required this.email,
    required this.schema,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cnpj': cnpj,
      'razao': razao,
      'fantasia': fantasia,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'municipio': municipio,
      'uf': uf,
      'telefone': telefone,
      'email': email,
      'schema': schema,
    };
  }

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'].toInt() ?? 0,
      cnpj: json['cnpj'] ?? '',
      razao: json['razao'] ?? '',
      fantasia: json['fantasia'] ?? '',
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      numero: json['numero'] ?? '',
      bairro: json['bairro'] ?? '',
      municipio: json['municipio'] ?? '',
      uf: json['uf'] ?? '',
      telefone: json['telefone'] ?? '',
      email: json['email'] ?? '',
      schema: json['schema'] ?? '',
    );
  }
}
