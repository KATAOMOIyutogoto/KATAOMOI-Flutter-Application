# KATAOMOI App テストガイド

このディレクトリには、KATAOMOIアプリの包括的なテストスイートが含まれています。

## テストファイル構成

### 1. `kataomoi_app_test.dart`
**ウィジェットテスト** - UIコンポーネントの動作をテスト
- ホームページの表示テスト
- カードID入力の検証テスト
- ページ遷移のテスト
- エラーハンドリングのテスト

### 2. `repository_test.dart`
**リポジトリテスト** - データアクセス層のテスト
- CardRepositoryのテスト
- ClaimRepositoryのテスト
- APIレスポンスの処理テスト
- エラーケースのテスト

### 3. `provider_test.dart`
**プロバイダーテスト** - 状態管理のテスト
- CardProviderの状態変化テスト
- ClaimProviderの状態変化テスト
- モックリポジトリを使用したテスト
- エラー状態のテスト

### 4. `integration_test.dart`
**統合テスト** - アプリ全体の動作テスト
- エンドツーエンドのフローテスト
- ナビゲーションテスト
- パフォーマンステスト
- レスポンシブデザインテスト

### 5. `run_tests.dart`
**テスト実行ヘルパー** - テスト実行の支援機能

## テスト実行方法

### すべてのテストを実行
```bash
flutter test
```

### 特定のテストファイルを実行
```bash
flutter test test/kataomoi_app_test.dart
flutter test test/repository_test.dart
flutter test test/provider_test.dart
```

### 統合テストを実行
```bash
flutter test integration_test/
```

### テストカバレッジを確認
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## テストデータ

### テスト用カードID
- `550e8400-e29b-41d4-a716-446655440000` - 正常なカード
- `550e8400-e29b-41d4-a716-446655440001` - 正常なカード
- `550e8400-e29b-41d4-a716-446655440002` - 正常なカード
- `non-existent-card` - 存在しないカード（エラーテスト用）

### テスト用メールアドレス
- `test@example.com` - 正常なメールアドレス
- `invalid-email` - 無効なメールアドレス（エラーテスト用）

### テスト用OTP
- `123456` - 正常なOTP
- `000000` - 無効なOTP（エラーテスト用）

## モックデータ

### Card Entity
```dart
Card(
  id: '550e8400-e29b-41d4-a716-446655440000',
  status: 'preprovisioned',
  currentUrl: 'https://kataomoi.org',
  defaultSource: 'org_default',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
)
```

### ClaimToken Entity
```dart
ClaimToken(
  token: 'claim-token-123',
  cardId: '550e8400-e29b-41d4-a716-446655440000',
  expiresAt: DateTime.now().add(Duration(hours: 1)),
)
```

## テストのベストプラクティス

### 1. テストの命名規則
- `testWidgets` - ウィジェットテスト
- `test` - 単体テスト
- テスト名は日本語で分かりやすく記述

### 2. テストの構造
```dart
testWidgets('テストの説明', (WidgetTester tester) async {
  // Arrange - テストの準備
  await tester.pumpWidget(/* ウィジェット */);
  
  // Act - テストの実行
  await tester.tap(find.byType(Button));
  await tester.pump();
  
  // Assert - 結果の検証
  expect(find.text('期待する結果'), findsOneWidget);
});
```

### 3. モックの使用
- 外部依存をモック化
- テストデータは一箇所で管理
- エラーケースも含めてテスト

### 4. 非同期処理のテスト
```dart
await tester.pumpAndSettle(); // 非同期処理の完了を待機
```

## トラブルシューティング

### よくある問題

**テストが失敗する場合**
- モックデータが正しく設定されているか確認
- 非同期処理の待機時間が適切か確認
- テスト環境の依存関係が正しくインストールされているか確認

**統合テストが失敗する場合**
- 実際のAPI接続が必要な場合は、モックを使用
- デバイスの状態を確認
- テストデータの整合性を確認

**パフォーマンステストが失敗する場合**
- テスト環境の性能を確認
- タイムアウト時間を調整
- 不要な処理を削除

## 継続的インテグレーション

### GitHub Actions設定例
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test
      - run: flutter test --coverage
```

## 参考資料

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)

