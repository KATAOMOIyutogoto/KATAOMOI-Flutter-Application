# iOS Setup for KATAOMOI APP

## 必要な設定

### 1. Xcodeでの設定

1. **Bundle Identifier**: `com.yourcompany.kataomoi` に変更
2. **Team**: あなたのApple Developer Teamを選択
3. **Signing**: Automatic signingを有効化

### 2. Capabilities

以下のCapabilitiesを有効化してください：

- **Near Field Communication Tag Reading**: NFC機能のため
- **Associated Domains**: ディープリンクのため（必要に応じて）

### 3. Info.plist設定

以下の設定が既に含まれています：

- `NFCReaderUsageDescription`: NFC使用時の説明文
- `com.apple.developer.nfc.readersession.formats`: NFCタグ形式（TAG, NDEF）

### 4. 必要なデバイス

- **iPhone 7以降**: NFC機能が利用可能
- **iPhone XS以降**: バックグラウンドNFCタグ読み取りが可能

## ビルド方法

```bash
# 依存関係のインストール
cd ios
pod install

# アプリのビルド
flutter build ios

# デバッグビルド
flutter run -d ios
```

## トラブルシューティング

### NFC機能が動作しない場合

1. **デバイス設定**: 設定 > NFC が有効になっているか確認
2. **アプリ権限**: 初回起動時にNFC権限が許可されているか確認
3. **デバイス対応**: iPhone 7以降であることを確認

### ビルドエラーの場合

1. **Podの再インストール**:
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   ```

2. **Flutterクリーン**:
   ```bash
   flutter clean
   flutter pub get
   ```

## 配布

### TestFlight配布

1. XcodeでArchiveを作成
2. App Store Connectにアップロード
3. TestFlightでテスターに配布

### App Store配布

1. App Store Connectでアプリ情報を設定
2. 審査用のスクリーンショットを準備
3. プライバシーポリシーを設定
4. 審査提出
