import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConstants {
  // Supabase設定（デフォルト値付き）
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key';
  static String get supabaseServiceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? 'your-service-role-key';
  
  // Workers設定
  static String get appDeepLinkScheme => dotenv.env['APP_DEEP_LINK_SCHEME'] ?? 'kataomoiapp';
  static String get goDomain => dotenv.env['GO_DOMAIN'] ?? 'https://go.kataomoi.jp';
  static String get fallbackUrl => dotenv.env['FALLBACK_URL'] ?? 'https://kataomoi.jp/safety';
  
  // API設定
  static String get baseUrl => supabaseUrl;
  static Duration get apiTimeout => const Duration(seconds: 30);
  
  // 設定の検証
  static bool get isConfigured => 
      supabaseUrl != 'https://your-project.supabase.co' && 
      supabaseAnonKey != 'your-anon-key';
}


