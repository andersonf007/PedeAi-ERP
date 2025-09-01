import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

class QuantidadeDialog extends StatefulWidget {
  final double quantidadeAtual;
  final String nomeProduto;
  final double precoUnitario;

  const QuantidadeDialog({Key? key, required this.quantidadeAtual, required this.nomeProduto, required this.precoUnitario}) : super(key: key);

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
    quantidadeDigitada = widget.quantidadeAtual > 0 ? widget.quantidadeAtual.toString() : "";
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
        quantidadeDigitada = quantidadeDigitada.substring(0, quantidadeDigitada.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.nomeProduto,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                'R\$ ${widget.precoUnitario.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text('$quantidade x R\$ ${widget.precoUnitario.toStringAsFixed(2)}', style: TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
          Text(
            'Total: R\$ ${valorTotal.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          Text('Quantidade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Colors.red),
                onPressed: () {
                  if (quantidade > 0) {
                    setState(() {
                      quantidadeDigitada = (quantidade - 1).toString();
                      if (quantidadeDigitada == "0") quantidadeDigitada = "";
                    });
                  }
                },
              ),
              Text(quantidadeDigitada.isEmpty ? "0" : quantidadeDigitada, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  setState(() {
                    quantidadeDigitada = (quantidade + 1).toString();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          NumericKeyboard(
            onKeyboardTap: _onKeyboardTap,
            textColor: Colors.black,
            rightButtonFn: _onBackspace,
            rightIcon: Icon(Icons.backspace, color: Colors.red),
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
          child: Text("Cancelar", style: TextStyle(color: Colors.red)),
          onPressed: () => Navigator.pop(context, null),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: quantidade == 0 ? null : () => Navigator.pop(context, quantidade),
          child: const Text("Confirmar"),
        ),
      ],
    );
  }
}
