# KATAOMOI APP セットアップガイド

## 前提条件

- Flutter SDK 3.0.0以上
- Node.js 18以上（Cloudflare Workers用）
- Supabaseアカウント
- Cloudflareアカウント

## 1. Supabaseプロジェクトの設定

### 1.1 プロジェクト作成
1. [Supabase](https://supabase.com)にアクセス
2. 「New Project」をクリック
3. プロジェクト名を入力（例：kataomoi-app）
4. データベースパスワードを設定
5. リージョンを選択（推奨：Asia Northeast (Tokyo)）

### 1.2 データベーススキーマの適用
1. Supabaseダッシュボードの「SQL Editor」を開く
2. `supabase/schema.sql` の内容をコピー&ペースト
3. 「Run」ボタンをクリックして実行
4. `supabase/seed.sql` の内容も同様に実行

### 1.3 APIキーの取得
1. 「Settings」→「API」を開く
2. 以下の値をメモ：
   - Project URL
   - anon public key
   - service_role secret key

## 2. Cloudflare Workersの設定

### 2.1 ドメインの設定
1. [Cloudflare](https://cloudflare.com)にアクセス
2. 「Add a Site」で `go.kataomoi.jp` を追加
3. DNS設定でAレコードを設定（任意のIPアドレス）

### 2.2 Workerの作成
1. 「Workers & Pages」を開く
2. 「Create application」→「Create Worker」
3. Worker名を入力（例：kataomoi-redirect）
4. `workers/redirect/src/index.ts` の内容をコピー&ペースト

### 2.3 Worker Secretsの設定
1. Workerの「Settings」→「Variables」を開く
2. 「Add variable」で以下を追加：
   - `SUPABASE_URL`: SupabaseのProject URL
   - `SUPABASE_SERVICE_ROLE`: Supabaseのservice_role key
   - `APP_DEEP_LINK_SCHEME`: `kataomoiapp`
   - `FALLBACK_URL`: `https://kataomoi.jp/safety`

### 2.4 ルートの設定
1. Workerの「Triggers」を開く
2. 「Add route」をクリック
3. Route pattern: `go.kataomoi.jp/c/*`
4. Zone: `kataomoi.jp`

### 2.5 デプロイ
1. 「Save and Deploy」をクリック
2. デプロイが完了するまで待機

## 3. Flutterアプリの設定

### 3.1 環境変数の設定
1. `.env.example` を `.env` にコピー
2. `.env` ファイルを編集：
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   APP_DEEP_LINK_SCHEME=kataomoiapp
   GO_DOMAIN=https://go.kataomoi.jp
   FALLBACK_URL=https://kataomoi.jp/safety
   ```

### 3.2 依存関係のインストール
```bash
flutter pub get
```

### 3.3 コード生成（必要に応じて）
```bash
flutter packages pub run build_runner build
```

### 3.4 アプリの起動
```bash
flutter run
```

## 4. テスト手順

### 4.1 基本動作テスト
1. アプリを起動
2. テスト用カードID（`550e8400-e29b-41d4-a716-446655440000`）を入力
3. 「カード詳細を表示」をクリック
4. カード情報が表示されることを確認

### 4.2 Claim機能テスト
1. 「カードをClaim」をクリック
2. メールアドレスを入力
3. OTPを入力（実際のメール送信は実装が必要）
4. Claimが完了することを確認

### 4.3 リダイレクトテスト
1. ブラウザで `https://go.kataomoi.jp/c/550e8400-e29b-41d4-a716-446655440000` にアクセス
2. 未Claimの場合はディープリンクにリダイレクト
3. Claim済みの場合は設定されたURLにリダイレクト

## 5. トラブルシューティング

### 5.1 よくある問題

**Supabase接続エラー**
- APIキーが正しく設定されているか確認
- ネットワーク接続を確認
- Supabaseプロジェクトがアクティブか確認

**Cloudflare Workerエラー**
- Worker Secretsが正しく設定されているか確認
- ルート設定が正しいか確認
- Workerのログを確認

**Flutterアプリエラー**
- `.env` ファイルが正しく配置されているか確認
- 依存関係が正しくインストールされているか確認
- デバッグログを確認

### 5.2 ログの確認方法

**Supabase**
- Dashboard → Logs でAPIログを確認

**Cloudflare Worker**
- Worker → Logs で実行ログを確認

**Flutter**
- `flutter logs` でアプリログを確認

## 6. 本番環境への移行

### 6.1 セキュリティ設定
1. SupabaseのRLSポリシーを確認
2. Cloudflareのセキュリティ設定を有効化
3. 環境変数の機密性を確保

### 6.2 パフォーマンス最適化
1. Cloudflareのキャッシュ設定を調整
2. Supabaseのインデックスを最適化
3. Flutterアプリのビルド最適化

### 6.3 監視設定
1. Supabaseの監視アラートを設定
2. Cloudflareのアナリティクスを確認
3. アプリのクラッシュレポートを設定


