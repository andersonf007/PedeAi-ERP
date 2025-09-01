import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:pedeai/model/forma_pagamento.dart';

class PagamentoDialog extends StatefulWidget {
  final FormaPagamento forma;
  final double valorRestante;

  const PagamentoDialog({
    super.key,
    required this.forma,
    required this.valorRestante,
  });

  @override
  State<PagamentoDialog> createState() => _PagamentoDialogState();
}

class _PagamentoDialogState extends State<PagamentoDialog> {
  String valorDigitado = "";

  void _onKeyboardTap(String text) {

    setState(() {
      if (text == ',' || text == '.') {
        // Permite apenas um separador decimal
        if (!valorDigitado.contains('.') && !valorDigitado.contains(',')) {
          valorDigitado += '.';
        }
      } else {
        valorDigitado += text;
      }
    });

  }

  double get valorDesejadoPagar {
    if (valorDigitado.isEmpty) return 0.0;
    return double.tryParse(valorDigitado) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    double troco = 0.0;
    if (widget.forma.tipoFormaPagamentoId == 1 &&
        valorDesejadoPagar > widget.valorRestante) {
      troco = valorDesejadoPagar - widget.valorRestante;
    }

    return AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Align(
        alignment: Alignment.center,
        child: Text(
          widget.forma.nome ?? '',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Valor restante: R\$ ${widget.valorRestante.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            "Valor digitado: R\$ ${valorDesejadoPagar.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 14, color: cs.onSurface),
          ),
          if (troco > 0 && widget.forma.tipoFormaPagamentoId == 1)
            Text("Troco: R\$ ${troco.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14, color: Colors.green)),
          if (valorDesejadoPagar > widget.valorRestante &&
              widget.forma.tipoFormaPagamentoId != 1)
            Text("Essa forma de pagamento não permite troco",
                style: TextStyle(fontSize: 14, color: cs.error)),

          const SizedBox(height: 12),

          // Teclado numérico
          NumericKeyboard(
            onKeyboardTap: _onKeyboardTap,
            textColor: cs.onSurface,
            rightButtonFn: () {
              setState(() {
                if (valorDigitado.isNotEmpty) {
                  valorDigitado =
                      valorDigitado.substring(0, valorDigitado.length - 1);
                }
              });
            },
            rightIcon: Icon(Icons.backspace, color: cs.error),
          ),
          // Botão extra para vírgula
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: Size(48, 48)),
                onPressed: () {
                  setState(() {
                    if (!valorDigitado.contains('.') && !valorDigitado.contains(',')) {
                      valorDigitado += '.';
                    }
                  });
                },
                child: Text(',', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Cancelar", style: TextStyle(color: cs.primary)),
          onPressed: () => Navigator.pop(context, null),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Confirmar"),
          onPressed: () {
            if (widget.forma.tipoFormaPagamentoId != 1 &&
                valorDesejadoPagar > widget.valorRestante) return;
            if (valorDesejadoPagar == 0) return;
            Navigator.pop(
                context, {'valor': valorDesejadoPagar, 'troco': troco});
          },
        ),
      ],
    );
  }
}
