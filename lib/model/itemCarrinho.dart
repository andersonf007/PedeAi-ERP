import 'package:pedeai/model/produto.dart';

class ItemCarrinho {
  final Produto produto;
  int quantidade;
  
  ItemCarrinho({required this.produto, this.quantidade = 1});
  
  double get valorTotal => produto.preco * quantidade;
}