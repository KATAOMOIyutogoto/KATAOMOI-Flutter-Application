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

  Future<void> _startNfcScan() async {
    if (!_isNfcAvailable) {
      _showErrorSnackBar('NFCが利用できません。デバイスの設定を確認してください。');
      return;
    }

    ref.read(nfcProvider.notifier).startScanning();

    await NfcService.startNfcSession(
      onNfcDetected: (data) {
        ref.read(nfcProvider.notifier).onNfcDetected(data);
        widget.onNfcDetected?.call(data);
        _showSuccessSnackBar('NFCデータを取得しました: $data');
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
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(
                widget.icon ?? Icons.nfc,
                color: Colors.white,
                size: 24,
              ),
            const SizedBox(width: 12),
            Text(
              nfcState is NfcScanning
                  ? 'NFC読み取り中...'
                  : widget.buttonText ?? 'NFCを読み取り',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

