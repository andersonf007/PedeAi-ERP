class ScriptVenda {
  String detectarFonteVendas(String schema) {
    return """
      SELECT tablename
      FROM pg_catalog.pg_tables
      WHERE schemaname = '{schema}'
        AND (
          tablename IN ('vw_vendas_resumo','vendas','venda')
          OR tablename ILIKE '%venda%'
        )
      ORDER BY CASE
        WHEN tablename = 'vw_vendas_resumo' THEN 0
        WHEN tablename = 'vendas' THEN 1
        WHEN tablename = 'venda' THEN 2
        ELSE 10
      END, tablename
      LIMIT 1;
    """;
  }

  String detectarColunaData(String schema, String fonte) {
    return """
      SELECT column_name AS col
      FROM information_schema.columns
      WHERE table_schema = '{schema}' AND table_name = '$fonte'
        AND column_name IN ('data','data_venda','created_at','data_fechamento','data_abertura')
      ORDER BY CASE column_name
        WHEN 'data' THEN 0
        WHEN 'data_venda' THEN 1
        WHEN 'created_at' THEN 2
        WHEN 'data_fechamento' THEN 3
        WHEN 'data_abertura' THEN 4
        ELSE 10 END
      LIMIT 1;
    """;
  }

  String montarListagem(String schema, String fonte, {String? colunaData, DateTime? inicio, DateTime? fim, int limit = 500}) {
    final hasFiltro = (colunaData != null && (inicio != null || fim != null));

    String where = '';
    if (hasFiltro) {
      final startIso = (inicio ?? DateTime(1970)).toIso8601String();
      final endRaw = fim ?? DateTime.now();
      final end = DateTime(endRaw.year, endRaw.month, endRaw.day, 23, 59, 59);
      final endIso = end.toIso8601String();
      where = "WHERE \"$colunaData\" BETWEEN '$startIso' AND '$endIso'";
    }

    final orderBy = (colunaData != null) ? 'ORDER BY "' + colunaData + '" DESC' : 'ORDER BY 1 DESC';
    final dataAlias = (colunaData != null) ? ', "' + colunaData + '" as data' : ', NULL as data';

    // Observação: o alias "data" é útil para a tela usar fallback consistente
    return 'SELECT *' + dataAlias + ' FROM ' + schema + '.' + fonte + (where.isEmpty ? '' : ' ' + where) + ' ' + orderBy + ' LIMIT ' + limit.toString();
  }
}
