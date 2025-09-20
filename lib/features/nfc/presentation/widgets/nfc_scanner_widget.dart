import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nfc_provider.dart';
import '../../../../core/services/nfc_service.dart';

class NfcScannerWidget extends ConsumerStatefulWidget {
  final Function(String)? onNfcDetected;
  final String? buttonText;
  final IconData? icon;

  const NfcScannerWidget({
    super.key,
    this.onNfcDetected,
    this.buttonText,
    this.icon,
  });

  @override
  ConsumerState<NfcScannerWidget> createState() => _NfcScannerWidgetState();
}

class _NfcScannerWidgetState extends ConsumerState<NfcScannerWidget> {
  bool _isNfcAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    final isAvailable = await NfcService.isNfcAvailable();
    setState(() {
      _isNfcAvailable = isAvailable;
    });
  }

  String? _extractCardIdFromUrl(String url) {
    try {
      print('NFC URL解析: $url'); // デバッグ用
      
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // URLが go.kataomoi.org/c/:cardId または go.kataomoi.jp/c/:cardId の形式かチェック
      if (pathSegments.length >= 2 && pathSegments[0] == 'c') {
        final cardId = pathSegments[1];
        print('パスセグメントから抽出: $cardId'); // デバッグ用
        return cardId;
      }
      
      // その他の形式のURLからもIDを抽出を試行（より柔軟な正規表現）
      final regex = RegExp(r'/c/([a-f0-9\-]{36})', caseSensitive: false);
      final match = regex.firstMatch(url);
      if (match != null) {
        final cardId = match.group(1);
        print('正規表現から抽出: $cardId'); // デバッグ用
        return cardId;
      }
      
      // UUID形式のIDを直接検索（最後の手段）
      final uuidRegex = RegExp(r'([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})', caseSensitive: false);
      final uuidMatch = uuidRegex.firstMatch(url);
      if (uuidMatch != null) {
        final cardId = uuidMatch.group(1);
        print('UUID正規表現から抽出: $cardId'); // デバッグ用
        return cardId;
      }
      
      print('ID抽出失敗: $url'); // デバッグ用
      return null;
    } catch (e) {
      print('URL解析エラー: $e'); // デバッグ用
      return null;
    }
  }

  Future<void> _startNfcScan() async {
    if (!_isNfcAvailable) {
      _showErrorSnackBar('NFCが利用できません。デバイスの設定を確認してください。');
      return;
    }

    ref.read(nfcProvider.notifier).startScanning();

    await NfcService.startNfcSession(
      onNfcDetected: (data) {
        ref.read(nfcProvider.notifier).onNfcDetected(data);
        
        // URLからカードIDを抽出
        final cardId = _extractCardIdFromUrl(data);
        final displayData = cardId ?? data;
        
        widget.onNfcDetected?.call(displayData);
        _showSuccessSnackBar('NFCデータを取得しました: $displayData');
      },
      onError: (error) {
        ref.read(nfcProvider.notifier).onNfcError(error);
        _showErrorSnackBar(error);
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nfcState = ref.watch(nfcProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.6),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isNfcAvailable && nfcState is! NfcScanning ? _startNfcScan : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (nfcState is NfcScanning)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            else
              Icon(
                widget.icon ?? Icons.nfc,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            const SizedBox(width: 12),
            Text(
              nfcState is NfcScanning
                  ? 'NFC読み取り中...'
                  : widget.buttonText ?? 'NFCを読み取り',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



