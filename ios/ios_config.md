# iOS Configuration Guide

## 設定手順

### 1. Xcodeプロジェクトの設定

1. **Xcodeでプロジェクトを開く**:
   ```
   open ios/Runner.xcworkspace
   ```

2. **Bundle Identifier設定**:
   - `com.yourcompany.kataomoi` に変更
   - あなたのApple Developer Accountに合わせて調整

3. **Team設定**:
   - Signing & Capabilities タブでTeamを選択
   - Automatic signingを有効化

### 2. Capabilities設定

**Signing & Capabilities** タブで以下を追加：

- **Near Field Communication Tag Reading**
  - NFC機能のため

### 3. ビルド設定

**Build Settings** で以下を確認：

- **iOS Deployment Target**: 11.0以上
- **Swift Language Version**: Swift 5

### 4. 実行方法

```bash
# 依存関係のインストール
flutter pub get
cd ios && pod install && cd ..

# デバッグ実行
flutter run -d ios

# リリースビルド
flutter build ios --release
```

### 5. トラブルシューティング

#### Podのエラーが発生した場合
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
```

#### ビルドエラーが発生した場合
```bash
flutter clean
flutter pub get
```

### 6. 配布準備

#### TestFlight配布
1. Xcodeで Archive を作成
2. App Store Connect にアップロード
3. TestFlight でテスターに配布

#### App Store配布
1. App Store Connect でアプリ情報を設定
2. スクリーンショットを準備
3. プライバシーポリシーを設定
4. 審査提出
