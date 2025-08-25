import 'package:flutter/material.dart';
import 'package:pedeai/Commom/supabaseConf.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pedeai/theme/theme_controller.dart';
import 'package:pedeai/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Theme controller (1 única instância)
  final themeController = ThemeController();
  await themeController.load();

  // Rode o app passando o controller para o AppWidget
  runApp(AppWidget(themeController: themeController));
}
