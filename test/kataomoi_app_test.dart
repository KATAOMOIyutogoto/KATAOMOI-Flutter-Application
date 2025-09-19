import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kataomoi_app/main.dart';
import 'package:kataomoi_app/features/home/presentation/pages/home_page.dart';
import 'package:kataomoi_app/features/claim/presentation/pages/claim_page.dart';
import 'package:kataomoi_app/features/cards/presentation/pages/card_detail_page.dart';

void main() {
  group('KATAOMOI App Tests', () {
    testWidgets('ホームページが正常に表示される', (WidgetTester tester) async {
      // アプリを起動
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // タイトルが表示されているか確認
      expect(find.text('KATAOMOI APP'), findsOneWidget);
      expect(find.text('NFC名刺アプリへようこそ！'), findsOneWidget);
      expect(find.text('カードIDを入力して操作を開始してください'), findsOneWidget);
      
      // カードID入力フィールドが存在するか確認
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('カードID'), findsOneWidget);
      
      // ボタンが存在するか確認
      expect(find.text('カード詳細を表示'), findsOneWidget);
      expect(find.text('カードをClaim'), findsOneWidget);
      
      // テスト用カードIDが表示されているか確認
      expect(find.text('テスト用カードID'), findsOneWidget);
      expect(find.text('550e8400-e29b-41d4-a716-446655440000'), findsOneWidget);
    });

    testWidgets('カードID入力なしでボタンを押すとエラーメッセージが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // カード詳細ボタンをタップ
      await tester.tap(find.text('カード詳細を表示'));
      await tester.pump();

      // エラーメッセージが表示されるか確認
      expect(find.text('カードIDを入力してください'), findsOneWidget);
    });

    testWidgets('カードID入力後にカード詳細ページに遷移する', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
            routes: {
              '/card-detail': (context) => const CardDetailPage(cardId: 'test-card-id'),
            },
          ),
        ),
      );

      // カードIDを入力
      await tester.enterText(find.byType(TextField), '550e8400-e29b-41d4-a716-446655440000');
      
      // カード詳細ボタンをタップ
      await tester.tap(find.text('カード詳細を表示'));
      await tester.pump();

      // カード詳細ページに遷移するか確認
      expect(find.text('カード詳細'), findsOneWidget);
    });

    testWidgets('カードID入力後にClaimページに遷移する', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
            routes: {
              '/claim': (context) => const ClaimPage(cardId: 'test-card-id'),
            },
          ),
        ),
      );

      // カードIDを入力
      await tester.enterText(find.byType(TextField), '550e8400-e29b-41d4-a716-446655440000');
      
      // Claimボタンをタップ
      await tester.tap(find.text('カードをClaim'));
      await tester.pump();

      // Claimページに遷移するか確認
      expect(find.text('カードをClaim'), findsOneWidget);
      expect(find.text('NFC名刺をClaimするには、メールアドレスを入力してください'), findsOneWidget);
    });

    testWidgets('Claimページでメールアドレス入力フィールドが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ClaimPage(cardId: 'test-card-id'),
          ),
        ),
      );

      // メールアドレス入力フィールドが存在するか確認
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('メールアドレス'), findsOneWidget);
      
      // OTP送信ボタンが存在するか確認
      expect(find.text('OTPを送信'), findsOneWidget);
    });

    testWidgets('カード詳細ページが正常に表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CardDetailPage(cardId: 'test-card-id'),
          ),
        ),
      );

      // カード詳細ページの要素が表示されるか確認
      expect(find.text('カード詳細'), findsOneWidget);
      expect(find.text('カードID'), findsOneWidget);
      expect(find.text('ステータス'), findsOneWidget);
      expect(find.text('リダイレクトURL'), findsOneWidget);
      
      // リダイレクトテストボタンが存在するか確認
      expect(find.byIcon(Icons.open_in_browser), findsOneWidget);
    });
  });

  group('Widget Tests', () {
    testWidgets('CustomButtonが正常に表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomButton(
                text: 'テストボタン',
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      // ボタンが表示されるか確認
      expect(find.text('テストボタン'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('CustomButtonのローディング状態が正常に表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomButton(
                text: 'テストボタン',
                onPressed: null,
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      // ローディングインジケーターが表示されるか確認
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

// CustomButtonのインポートが必要
import 'package:kataomoi_app/shared/widgets/custom_button.dart';

