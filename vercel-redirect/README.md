# KATAOMOI リダイレクトサーバー

Vercelで動作するリダイレクトサーバーです。

## 機能

- 短縮URL: `https://your-domain.vercel.app/c/{cardId}`
- Supabaseからカード情報を取得
- 実際のURLにリダイレクト
- エラー時はフォールバックURLにリダイレクト

## セットアップ

1. **Vercel CLIのインストール**
   ```bash
   npm install -g vercel
   ```

2. **依存関係のインストール**
   ```bash
   npm install
   ```

3. **環境変数の設定**
   - Vercel Dashboardで環境変数を設定
   - または `vercel env add` コマンドで設定

4. **デプロイ**
   ```bash
   vercel --prod
   ```

## 環境変数

- `SUPABASE_URL`: SupabaseプロジェクトのURL
- `SUPABASE_SERVICE_ROLE_KEY`: SupabaseのService Role Key
- `FALLBACK_URL`: エラー時のフォールバックURL

## 使用方法

```
https://your-domain.vercel.app/c/550e8400-e29b-41d4-a716-446655440000
```

このURLにアクセスすると、Supabaseからカード情報を取得し、設定されたURLにリダイレクトされます。

