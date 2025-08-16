class Produto {
  final int id;
  final DateTime createdAt;
  final String descricao;
  final String codigo;
  final double preco;
  final int estoque;
  final int produtoIdPublic;
  final int id_unidade;
  final int id_categoria;

  Produto({
    required this.id,
    required this.createdAt,
    required this.descricao,
    required this.codigo,
    required this.preco,
    required this.estoque,
    required this.produtoIdPublic,
    required this.id_unidade,
    required this.id_categoria,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'descricao': descricao,
      'codigo': codigo,
      'preco': preco,
      'estoque': estoque,
      'produto_id_public': produtoIdPublic,
      'id_unidade': id_unidade,
      'id_categoria': id_categoria,
    };
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id']?.toInt() ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      descricao: json['descricao'] ?? '',
      codigo: json['codigo'] ?? '',
      preco: (json['preco'] ?? 0).toDouble(),
      estoque: json['estoque']?.toInt() ?? 0,
      produtoIdPublic: json['produto_id_public']?.toInt() ?? 0,
      id_unidade: json['id_unidade']?.toInt() ?? 0,
      id_categoria: json['id_categoria']?.toInt() ?? 0,
    );
  }

  // Método para formatar o preço
  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  
  // Método para formatar unidades
  String get unidadesFormatado => '$estoque unidades';
}