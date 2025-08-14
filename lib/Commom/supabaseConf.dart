import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://xqooosuvrybpxluryobh.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhxb29vc3V2cnlicHhsdXJ5b2JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2Mzk1ODAsImV4cCI6MjA3MDIxNTU4MH0.8ZuMSSk4zHCV-xXqrMBL7wYaN4s-K90sbf4-AtpGBUc';
  static const String supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhxb29vc3V2cnlicHhsdXJ5b2JoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDYzOTU4MCwiZXhwIjoyMDcwMjE1NTgwfQ.Cht_KizsjaJcObDmzAsZFxHdnuYXTwXrl3EYAlbSEC4';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
  static SupabaseClient get adminClient => SupabaseClient(supabaseUrl, supabaseServiceRoleKey);
}
