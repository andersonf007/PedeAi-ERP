class Unidade {
  final int id;
  final String nome;
  final String sigla;
  
  Unidade({
    required this.id,
    required this.nome,
    required this.sigla,
  });
  
  factory Unidade.fromJson(Map<String, dynamic> json) {
    return Unidade(
      id: json['id'],
      nome: json['nome'],
      sigla: json['sigla'],
    );
  }
}