import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pedeai/view/home/home.dart';
import 'package:pedeai/view/login/login.dart';

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

      routes: {'/login': (context) => LoginPage(), '/home': (context) => HomePage()},
    );
  }
}
