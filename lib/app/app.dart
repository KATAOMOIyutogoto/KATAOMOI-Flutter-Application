import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/marble_background.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/claim/presentation/pages/claim_page.dart';
import '../features/cards/presentation/pages/card_detail_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  void _initUniLinks() {
    // Webプラットフォームではディープリンクを無効化
    if (kIsWeb) {
      return;
    }

    // アプリが起動中にディープリンクを受信
    getLinksStream().listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print('ディープリンクエラー: $err');
    });

    // アプリが起動時にディープリンクで開かれた場合
    getInitialLink().then((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    });
  }

  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    
    if (uri.scheme == 'kataomoiapp' && uri.host == 'claim') {
      final cardId = uri.queryParameters['card'];
      if (cardId != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MarbleBackground(
              child: ClaimPage(cardId: cardId),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KATAOMOI APP',
      theme: AppTheme.marbleTheme,
      home: const MarbleBackground(
        child: HomePage(),
      ),
      routes: {
        '/claim': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final cardId = args?['cardId'] as String?;
          if (cardId != null) {
            return MarbleBackground(
              child: ClaimPage(cardId: cardId),
            );
          }
          return const MarbleBackground(
            child: HomePage(),
          );
        },
        '/card-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final cardId = args?['cardId'] as String?;
          if (cardId != null) {
            return MarbleBackground(
              child: CardDetailPage(cardId: cardId),
            );
          }
          return const MarbleBackground(
            child: HomePage(),
          );
        },
      },
    );
  }
}