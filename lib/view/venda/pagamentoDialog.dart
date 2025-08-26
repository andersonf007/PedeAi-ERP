import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:pedeai/model/forma_pagamento.dart';

class PagamentoDialog extends StatefulWidget {
  final FormaPagamento forma; // forma de pagamento (ex: dinheiro, cartão)
  final double valorRestante; // quanto ainda falta pagar

  const PagamentoDialog({Key? key, required this.forma, required this.valorRestante}) : super(key: key);

  @override
  _PagamentoDialogState createState() => _PagamentoDialogState();
}

class _PagamentoDialogState extends State<PagamentoDialog> {
  String valorDigitado = "";

  void _onKeyboardTap(String text) {
    setState(() {
      valorDigitado += text;
    });
  }

  double get valorDesejadoPagar {
    if (valorDigitado.isEmpty) return 0.0;
    return double.tryParse(valorDigitado) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    double troco = 0.0;
    if (widget.forma.tipoFormaPagamentoId == 1 && valorDesejadoPagar > widget.valorRestante) {
      troco = valorDesejadoPagar - widget.valorRestante;
    }
    print(troco.toString());

    return AlertDialog(
      title: Align(alignment: Alignment.center, child: Text(widget.forma.nome)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Valor restante: R\$ ${widget.valorRestante.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Valor digitado: R\$ ${valorDesejadoPagar.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
          if (troco > 0 && widget.forma.tipoFormaPagamentoId == 1) Text("Troco: R\$ ${troco.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.green)),
          if (valorDesejadoPagar > widget.valorRestante && widget.forma.tipoFormaPagamentoId != 1) Text("Essa forma de pagamento não permite troco", style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 255, 0, 0))),
          SizedBox(height: 20),

          // Teclado numérico
          NumericKeyboard(
            onKeyboardTap: _onKeyboardTap,
            textColor: Colors.black,
            rightButtonFn: () {
              setState(() {
                if (valorDigitado.isNotEmpty) {
                  valorDigitado = valorDigitado.substring(0, valorDigitado.length - 1);
                }
              });
            },
            rightIcon: Icon(Icons.backspace, color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(child: Text("Cancelar"), onPressed: () => Navigator.pop(context, null)),
        ElevatedButton(
          child: Text("Confirmar"),
          onPressed: () {
            if (widget.forma.tipoFormaPagamentoId != 1 && valorDesejadoPagar > widget.valorRestante) return;
            if (valorDesejadoPagar == 0) return;
            // Retorna o valor digitado e o troco
            Navigator.pop(context, {'valor': valorDesejadoPagar, 'troco': troco});
          },
        ),
      ],
    );
  }
}
