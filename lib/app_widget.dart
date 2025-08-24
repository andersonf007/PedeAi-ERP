import 'package:flutter/material.dart';
import 'package:pedeai/model/usuario.dart';
import 'package:pedeai/view/estoque/estoque.dart';
import 'package:pedeai/view/home/home.dart';
import 'package:pedeai/view/login/login.dart';
import 'package:pedeai/view/produto/cadastroProduto.dart';
import 'package:pedeai/view/produto/listProdutos.dart';
import 'package:pedeai/view/usuario/cadastroUsuario.dart';
import 'package:pedeai/view/usuario/listUsuario.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final SupabaseClient supabase;

  @override
  void initState() {
    super.initState();
    // Pega o cliente já inicializado no main.dart
    supabase = Supabase.instance.client;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PedeAi ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      // sua configuração de rotas continua igual
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/listProdutos': (context) => ProductsListPage(),
        '/cadastro-produto': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as int?;
          return CadastroProdutoPage(produtoId: args);
        },
        '/listUsuarios': (context) => ListUsuarioPage(),
        '/cadastro-usuario': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Usuario?;
          return CadastroUsuarioPage(usuario: args);
        },
        '/estoque': (context) => EstoquePage(),
      },
    );
  }
}
