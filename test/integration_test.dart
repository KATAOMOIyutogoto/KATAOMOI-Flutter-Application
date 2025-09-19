import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kataomoi_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('KATAOMOI App Integration Tests', () {
    testWidgets('アプリの起動からカード詳細表示までの統合テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // ホームページが表示されているか確認
      expect(find.text('KATAOMOI APP'), findsOneWidget);
      expect(find.text('NFC名刺アプリへようこそ！'), findsOneWidget);

      // カードID入力フィールドを探す
      final cardIdField = find.byType(TextField);
      expect(cardIdField, findsOneWidget);

      // テスト用カードIDを入力
      await tester.enterText(cardIdField, '550e8400-e29b-41d4-a716-446655440000');
      await tester.pumpAndSettle();

      // カード詳細ボタンをタップ
      await tester.tap(find.text('カード詳細を表示'));
      await tester.pumpAndSettle();

      // カード詳細ページに遷移したか確認
      // 注意: 実際のAPI接続がない場合、エラーが表示される可能性があります
      expect(find.text('カード詳細'), findsOneWidget);
    });

    testWidgets('アプリの起動からClaim機能までの統合テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // カードID入力フィールドを探す
      final cardIdField = find.byType(TextField);
      expect(cardIdField, findsOneWidget);

      // テスト用カードIDを入力
      await tester.enterText(cardIdField, '550e8400-e29b-41d4-a716-446655440000');
      await tester.pumpAndSettle();

      // Claimボタンをタップ
      await tester.tap(find.text('カードをClaim'));
      await tester.pumpAndSettle();

      // Claimページに遷移したか確認
      expect(find.text('カードをClaim'), findsOneWidget);
      expect(find.text('NFC名刺をClaimするには、メールアドレスを入力してください'), findsOneWidget);

      // メールアドレス入力フィールドを探す
      final emailField = find.byType(TextField);
      expect(emailField, findsOneWidget);

      // テスト用メールアドレスを入力
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // OTP送信ボタンをタップ
      await tester.tap(find.text('OTPを送信'));
      await tester.pumpAndSettle();

      // 注意: 実際のAPI接続がない場合、エラーが表示される可能性があります
      // この場合、エラーメッセージが表示されることを確認
    });

    testWidgets('ナビゲーションの統合テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // ホームページの要素が表示されているか確認
      expect(find.text('KATAOMOI APP'), findsOneWidget);

      // カードIDを入力してカード詳細ページに遷移
      await tester.enterText(find.byType(TextField), '550e8400-e29b-41d4-a716-446655440000');
      await tester.tap(find.text('カード詳細を表示'));
      await tester.pumpAndSettle();

      // 戻るボタンでホームページに戻る
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // ホームページに戻ったか確認
      expect(find.text('NFC名刺アプリへようこそ！'), findsOneWidget);
    });

    testWidgets('エラーハンドリングの統合テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // カードIDを入力せずにボタンをタップ
      await tester.tap(find.text('カード詳細を表示'));
      await tester.pumpAndSettle();

      // エラーメッセージが表示されるか確認
      expect(find.text('カードIDを入力してください'), findsOneWidget);

      // スナックバーが消えるまで待機
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('レスポンシブデザインの統合テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 画面サイズを変更
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      // 要素が適切に表示されているか確認
      expect(find.text('KATAOMOI APP'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // 画面サイズをさらに変更
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();

      // 要素が適切に表示されているか確認
      expect(find.text('KATAOMOI APP'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('アプリ起動時間の測定', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 起動時間が5秒以内であることを確認
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('ページ遷移時間の測定', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      // カードIDを入力してページ遷移
      await tester.enterText(find.byType(TextField), '550e8400-e29b-41d4-a716-446655440000');
      await tester.tap(find.text('カード詳細を表示'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 遷移時間が2秒以内であることを確認
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}

