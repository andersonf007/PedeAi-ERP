import 'package:flutter/material.dart';
import 'package:pedeai/Commom/supabaseConf.dart';
import 'package:pedeai/app_widget.dart';
import 'package:pedeai/view/login/login.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    // Inicializa o Supabase antes de rodar a aplicação
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  runApp(Provider(create: (context) => LoginPage(), child: AppWidget()));
}
