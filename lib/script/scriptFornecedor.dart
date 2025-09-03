// lib/script/scriptFornecedor.dart

class ScriptFornecedor {
  String inserirFornecedor(String schema, Map<String, dynamic> dados) {
    // Helper para tratar valores nulos ou vazios como 'NULL' no SQL
    String formatValue(dynamic value) {
      if (value == null || value.toString().isEmpty) {
        return 'NULL';
      }
      // Adiciona aspas simples para strings
      return "'${value.toString().replaceAll("'", "''")}'";
    }

    return '''
      INSERT INTO ${schema}.fornecedor (
        razao_social, nome_fantasia, cnpj, ie, telefone, email, 
        cep, logradouro, numero, bairro, cidade, uf
      )
      VALUES (
        ${formatValue(dados['razao_social'])},
        ${formatValue(dados['nome_fantasia'])},
        ${formatValue(dados['cnpj'])},
        ${formatValue(dados['ie'])},
        ${formatValue(dados['telefone'])},
        ${formatValue(dados['email'])},
        ${formatValue(dados['cep'])},
        ${formatValue(dados['logradouro'])},
        ${formatValue(dados['numero'])},
        ${formatValue(dados['bairro'])},
        ${formatValue(dados['cidade'])},
        ${formatValue(dados['uf'])}
      ) RETURNING id;
    ''';
  }

  String buscarListaFornecedores(String schema) {
    return "SELECT * FROM ${schema}.fornecedor ORDER BY razao_social";
  }

  String buscarFornecedorPorId(int id, String schema) {
    return "SELECT * FROM ${schema}.fornecedor WHERE id = $id";
  }

  String atualizarFornecedor(String schema, Map<String, dynamic> dados) {
    final id = dados['id'];
    
    // Helper para criar a parte SET da query, ignorando campos nulos
    String createSetClause(Map<String, dynamic> data) {
      List<String> setClauses = [];
      data.forEach((key, value) {
        if (key != 'id' && value != null) {
          // Adiciona aspas para valores de texto
          final formattedValue = "'${value.toString().replaceAll("'", "''")}'";
          setClauses.add("$key = $formattedValue");
        } else if (key != 'id' && value == null) {
           setClauses.add("$key = NULL");
        }
      });
      return setClauses.join(', ');
    }

    final setClause = createSetClause(dados);

    return '''
      UPDATE ${schema}.fornecedor
      SET $setClause
      WHERE id = $id 
      RETURNING id;
    ''';
  }

  String deletarFornecedor(String schema, int id) {
    return "DELETE FROM ${schema}.fornecedor WHERE id = $id RETURNING id;";
  }
}