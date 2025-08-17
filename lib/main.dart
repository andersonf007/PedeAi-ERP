import 'package:flutter/material.dart';
import 'package:pedeai/Commom/supabaseConf.dart';
import 'package:pedeai/app_widget.dart';
import 'package:pedeai/view/login/login.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(Provider(create: (context) => LoginPage(), child: AppWidget()));
}
