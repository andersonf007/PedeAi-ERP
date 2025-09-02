class Caixa {
  final int id;
  final bool aberto;
  final DateTime dataAbertura;
  final DateTime dataFechamento;
  final String idUsuarioAbertura;
  final String idUsuarioFechamento;
  final double valorAbertura;
  final String periodoAbertura;
  final String periodoFechamento;

  Caixa({required this.id, required this.aberto, required this.dataAbertura, required this.dataFechamento, required this.idUsuarioAbertura, required this.idUsuarioFechamento, required this.valorAbertura, required this.periodoAbertura, required this.periodoFechamento});

  factory Caixa.fromJson(Map<String, dynamic> json) {
    return Caixa(
      id: json['id'] ?? 0,
      aberto: json['aberto'] ?? false,
      dataAbertura: json['data_abertura'] != null ? DateTime.tryParse(json['data_abertura'].toString()) ?? DateTime(2000, 1, 1, 0, 0, 0) : DateTime(2000, 1, 1, 0, 0, 0),
      dataFechamento: json['data_fechamento'] != null ? DateTime.tryParse(json['data_fechamento'].toString()) ?? DateTime(2099, 12, 31, 23, 59, 59) : DateTime(2099, 12, 31, 23, 59, 59),
      idUsuarioAbertura: json['id_usuario_abertura'] ?? '',
      idUsuarioFechamento: json['id_usuario_fechamento'] ?? '',
      valorAbertura: (json['valor_abertura'] is num) ? (json['valor_abertura'] as num).toDouble() : double.tryParse(json['valor_abertura']?.toString() ?? '') ?? 0.0,
      periodoAbertura: json['periodo_abertura']?.toString() ?? '',
      periodoFechamento: json['periodo_fechamento']?.toString() ?? '',
    );
  }
}
