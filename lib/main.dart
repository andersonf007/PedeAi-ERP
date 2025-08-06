// main.dart

import 'package:flutter/material.dart';
import 'package:pedeai/app_widget.dart';
import 'package:pedeai/view/login/login.dart';
import 'package:provider/provider.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(Provider(create: (context) => LoginPage(), child: AppWidget()));
}
