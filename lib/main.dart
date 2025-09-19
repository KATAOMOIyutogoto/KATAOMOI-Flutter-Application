import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';
import 'app/app.dart';
import 'core/network/dio_provider.dart';
import 'core/utils/debug_helper.dart';
import 'features/cards/data/repositories/card_repository_impl.dart';
import 'features/cards/domain/repositories/card_repository.dart';
import 'features/cards/presentation/providers/card_provider.dart';
import 'features/claim/data/repositories/claim_repository_impl.dart';
import 'features/claim/domain/repositories/claim_repository.dart';
import 'features/claim/presentation/providers/claim_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 環境変数を読み込み
    await dotenv.load(fileName: ".env");
    DebugHelper.printEnvironmentInfo();
  } catch (e) {
    DebugHelper.printError('環境変数読み込み', e);
    print('⚠️ .envファイルが見つかりません。デフォルト値を使用します。');
  }
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}