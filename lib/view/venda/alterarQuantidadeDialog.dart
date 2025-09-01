import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

class QuantidadeDialog extends StatefulWidget {
  final double quantidadeAtual;
  final String nomeProduto;
  final double precoUnitario;

  const QuantidadeDialog({
    super.key,
    required this.quantidadeAtual,
    required this.nomeProduto,
    required this.precoUnitario,
  });

  @override
  State<QuantidadeDialog> createState() => _QuantidadeDialogState();
}

class _QuantidadeDialogState extends State<QuantidadeDialog> {
  String quantidadeDigitada = "";


  double get quantidade {
    if (quantidadeDigitada.isEmpty) return 0;
    // Substitui vírgula por ponto para aceitar decimal
    return double.tryParse(quantidadeDigitada.replaceAll(',', '.')) ?? 0;
  }


  double get valorTotal => quantidade * widget.precoUnitario;

  @override
  void initState() {
    super.initState();
    quantidadeDigitada =
        widget.quantidadeAtual > 0 ? widget.quantidadeAtual.toString() : "";
  }

  void _onKeyboardTap(String text) {
    setState(() {
      if (text == ',' || text == '.') {
        // Permite apenas um separador decimal
        if (!quantidadeDigitada.contains('.') && !quantidadeDigitada.contains(',')) {
          quantidadeDigitada += '.';
        }
      } else {
        if (quantidadeDigitada == "0") {
          quantidadeDigitada = text;
        } else {
          quantidadeDigitada += text;
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (quantidadeDigitada.isNotEmpty) {
        quantidadeDigitada =
            quantidadeDigitada.substring(0, quantidadeDigitada.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                Text(widget.nomeProduto,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text('R\$ ${widget.precoUnitario.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text('$quantidade x R\$ ${widget.precoUnitario.toStringAsFixed(2)}',
                    style:
                        TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('Total: R\$ ${valorTotal.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: cs.onSurface)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text('Quantidade',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: cs.primary),
                onPressed: () {
                  if (quantidade > 0) {
                    setState(() {
                      quantidadeDigitada = (quantidade - 1).toString();
                      if (quantidadeDigitada == "0") quantidadeDigitada = "";
                    });
                  }
                },
              ),
              Text(quantidadeDigitada.isEmpty ? "0" : quantidadeDigitada,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add, color: cs.primary),
                onPressed: () =>
                    setState(() => quantidadeDigitada = (quantidade + 1).toString()),
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
          // Botão extra para vírgula
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: Size(48, 48)),
                onPressed: () {
                  setState(() {
                    if (!quantidadeDigitada.contains('.') && !quantidadeDigitada.contains(',')) {
                      quantidadeDigitada += '.';
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
          onPressed: quantidade == 0
              ? null
              : () => Navigator.pop(context, quantidade),
          child: const Text("Confirmar"),
        ),
      ],
    );
  }
}
