import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

class QuantidadeDialog extends StatefulWidget {
  final double quantidadeAtual;
  final String nomeProduto;
  final double precoUnitario;

  const QuantidadeDialog({super.key, required this.quantidadeAtual, required this.nomeProduto, required this.precoUnitario});

  @override
  State<QuantidadeDialog> createState() => _QuantidadeDialogState();
}

class _QuantidadeDialogState extends State<QuantidadeDialog> {
  String parteInteira = "";
  String parteDecimal = "";
  bool digitandoDecimal = false;

  double get quantidade {
    if (parteInteira.isEmpty) return 0;
    String valor = parteInteira;
    if (digitandoDecimal && parteDecimal.isNotEmpty) {
      valor += '.' + parteDecimal;
    }
    return double.tryParse(valor) ?? 0;
  }

  double get valorTotal => quantidade * widget.precoUnitario;

  @override
  void initState() {
    super.initState();
    final inicial = widget.quantidadeAtual;
    if (inicial > 0) {
      final partes = inicial.toString().split('.');
      parteInteira = partes[0];
      if (partes.length > 1 && partes[1] != '0') {
        parteDecimal = partes[1];
        digitandoDecimal = true;
      }
    }
  }

  void _onKeyboardTap(String text) {
    setState(() {
      if (text == ',' || text == '.') {
        if (!digitandoDecimal) digitandoDecimal = true;
      } else {
        if (!digitandoDecimal) {
          // Se parteInteira for "0", substitui
          if (parteInteira == "0") {
            parteInteira = text;
          } else {
            parteInteira += text;
          }
        } else {
          // Só permite até 3 casas decimais
          if (parteDecimal.length < 3) {
            parteDecimal += text;
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (digitandoDecimal && parteDecimal.isNotEmpty) {
        parteDecimal = parteDecimal.substring(0, parteDecimal.length - 1);
      } else if (digitandoDecimal && parteDecimal.isEmpty) {
        digitandoDecimal = false;
      } else if (parteInteira.isNotEmpty) {
        parteInteira = parteInteira.substring(0, parteInteira.length - 1);
        if (parteInteira.isEmpty) parteInteira = "0";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String quantidadeStr = parteInteira;
    if (digitandoDecimal) quantidadeStr += ',' + parteDecimal;

    return AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.nomeProduto,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${widget.precoUnitario.toStringAsFixed(2)}',
                  style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text('$quantidadeStr x R\$ ${widget.precoUnitario.toStringAsFixed(2)}', style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Total: R\$ ${valorTotal.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            'Quantidade',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: cs.primary),
                onPressed: () {
                  if (quantidade > 0) {
                    setState(() {
                      double nova = quantidade - 1;
                      final partes = nova.toString().split('.');
                      parteInteira = partes[0];
                      parteDecimal = (partes.length > 1 && partes[1] != '0') ? partes[1] : "";
                      digitandoDecimal = parteDecimal.isNotEmpty;
                    });
                  }
                },
              ),
              Text(quantidadeStr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add, color: cs.primary),
                onPressed: () {
                  setState(() {
                    double nova = quantidade + 1;
                    final partes = nova.toString().split('.');
                    parteInteira = partes[0];
                    parteDecimal = (partes.length > 1 && partes[1] != '0') ? partes[1] : "";
                    digitandoDecimal = parteDecimal.isNotEmpty;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          NumericKeyboard(
            onKeyboardTap: _onKeyboardTap,
            textColor: cs.onSurface,
            rightButtonFn: _onBackspace,
            rightIcon: Icon(Icons.backspace, color: cs.error),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: Size(48, 48)),
                onPressed: () {
                  setState(() {
                    if (!digitandoDecimal) digitandoDecimal = true;
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: quantidade == 0 ? null : () => Navigator.pop(context, quantidade),
          child: const Text("Confirmar"),
        ),
      ],
    );
  }
}
