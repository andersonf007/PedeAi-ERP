import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pedeai/model/usuario.dart';
import 'package:pedeai/view/home/home.dart';
import 'package:pedeai/view/login/login.dart';
import 'package:pedeai/view/login/selecionarEmpresa.dart';
import 'package:pedeai/view/produto/cadastroProduto.dart';
import 'package:pedeai/view/produto/listProdutos.dart';
import 'package:pedeai/view/usuario/cadastroUsuario.dart';
import 'package:pedeai/view/usuario/listUsuario.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: const [Locale('pt', 'BR')],
      title: 'Pede Ai ERP',
      theme: ThemeData(primaryColor: const Color(0xFF1e5977)),
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
      },
    );
  }
}
