#!/bin/bash

# iOS ビルドスクリプト for KATAOMOI APP

echo "🚀 KATAOMOI APP iOS ビルドを開始します..."

# 1. Flutterクリーン
echo "📦 Flutterクリーンを実行中..."
flutter clean

# 2. 依存関係のインストール
echo "📦 依存関係をインストール中..."
flutter pub get

# 3. iOS依存関係のインストール
echo "📦 iOS依存関係をインストール中..."
cd ios
pod install
cd ..

# 4. iOSビルド
echo "🔨 iOSビルドを実行中..."
flutter build ios --release

echo "✅ iOSビルドが完了しました！"
echo "📱 Xcodeでプロジェクトを開いて、デバイスにインストールまたはTestFlightに配布してください。"
