class Produto {
  final int id;
  final DateTime createdAt;
  final String descricao;
  final String codigo;
  final double preco;
  final double estoque;
  final int produtoIdPublic;
  final int id_unidade;
  final int id_categoria;
  final double precoCusto;
  final String validade;
  final String image_url;
  final bool ativo;
  Produto({required this.id, required this.createdAt, required this.descricao, required this.codigo, required this.preco, required this.estoque, required this.produtoIdPublic, required this.id_unidade, required this.id_categoria, required this.precoCusto, required this.validade, required this.image_url, required this.ativo});

  Map<String, dynamic> toJson() {
    return {'id': id, 'created_at': createdAt.toIso8601String(), 'descricao': descricao, 'codigo': codigo, 'preco_venda': preco, 'quantidade': estoque, 'produto_id_public': produtoIdPublic, 'id_unidade': id_unidade, 'id_categoria': id_categoria, 'preco_custo': precoCusto, 'validade': validade, 'image_url': image_url, 'ativo': ativo};
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id']?.toInt() ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      descricao: json['descricao'] ?? '',
      codigo: json['codigo'] ?? '',
      preco: (json['preco_venda'] ?? 0).toDouble(),
      estoque: json['quantidade']?.toDouble() ?? 0,
      produtoIdPublic: json['produto_id_public']?.toInt() ?? 0,
      id_unidade: json['id_unidade']?.toInt() ?? 0,
      id_categoria: json['id_categoria']?.toInt() ?? 0,
      precoCusto: (json['preco_custo'] ?? 0).toDouble(),
      validade: json['validade'] ?? '',
      image_url: json['image_url'] ?? '',
      ativo: json['ativo'] ?? true,
    );
  }

  // Método para formatar o preço
  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';

  // Método para formatar unidades
  String get unidadesFormatado => '$estoque unidades';
}
