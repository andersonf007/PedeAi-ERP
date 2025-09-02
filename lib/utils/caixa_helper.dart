import 'package:flutter/material.dart';
import 'package:pedeai/controller/caixaController.dart';

class CaixaHelper {
  static Future<void> verificarCaixaAbertoENavegar(BuildContext context, String rota) async {
    final caixaController = CaixaCotroller();
    try {
      int idCaixa = await caixaController.buscarCaixaAberto();
      if (idCaixa != null && idCaixa > 0) {
        Navigator.of(context).pushNamed(rota);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('O caixa está fechado!'), backgroundColor: Colors.red));
      }
    } on CaixaCotrollerException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao verificar caixa: $e'), backgroundColor: Colors.red));
    }
  }
}
