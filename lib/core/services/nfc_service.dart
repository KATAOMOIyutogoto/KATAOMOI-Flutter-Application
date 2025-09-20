import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:html' as html;

class NfcService {
  static Future<bool> isNfcAvailable() async {
    // Web環境ではNFC APIの利用可能性をチェック
    if (html.window.navigator.userAgent.contains('Chrome')) {
      // Chrome 89以降でWeb NFC APIが利用可能
      return true;
    }
    return false;
  }

  static Future<void> startNfcSession({
    required Function(String) onNfcDetected,
    required Function(String) onError,
  }) async {
    try {
      // Web環境ではWeb NFC APIを使用
      if (html.window.navigator.userAgent.contains('Chrome')) {
        // Web NFC APIの実装（実際の実装は複雑なため、デモ用の実装）
        _simulateNfcRead(onNfcDetected, onError);
      } else {
        // モバイル環境ではNfcManagerを使用
        await NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            try {
              final ndef = Ndef.from(tag);
              if (ndef != null) {
                final ndefMessage = await ndef.read();
                if (ndefMessage.records.isNotEmpty) {
                  final record = ndefMessage.records.first;
                  if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
                    final payload = record.payload;
                    final text = String.fromCharCodes(payload.skip(3));
                    onNfcDetected(text);
                  }
                }
              }
            } catch (e) {
              onError('NFC読み取りエラー: $e');
            }
          },
        );
      }
    } catch (e) {
      onError('NFCセッション開始エラー: $e');
    }
  }

  // Web用のNFC読み取りシミュレーション
  static void _simulateNfcRead(
    Function(String) onNfcDetected,
    Function(String) onError,
  ) {
    // デモ用のNFCデータをシミュレート（実際のURL形式）
    Future.delayed(const Duration(seconds: 2), () {
      onNfcDetected('https://go.kataomoi.org/c/550e8400-e29b-41d4-a716-446655440000');
    });
  }

  static Future<void> stopNfcSession() async {
    await NfcManager.instance.stopSession();
  }

  static Future<void> writeToNfc({
    required String text,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndef = Ndef.from(tag);
            if (ndef != null) {
              final ndefRecord = NdefRecord.createText(text);
              final ndefMessage = NdefMessage([ndefRecord]);
              await ndef.write(ndefMessage);
              onSuccess();
            } else {
              onError('このタグは書き込み可能ではありません');
            }
          } catch (e) {
            onError('NFC書き込みエラー: $e');
          }
        },
      );
    } catch (e) {
      onError('NFCセッション開始エラー: $e');
    }
  }
}
