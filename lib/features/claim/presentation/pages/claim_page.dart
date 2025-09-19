import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/claim_provider.dart';
import '../widgets/email_input_widget.dart';
import '../widgets/otp_input_widget.dart';

class ClaimPage extends ConsumerStatefulWidget {
  final String cardId;

  const ClaimPage({
    super.key,
    required this.cardId,
  });

  @override
  ConsumerState<ClaimPage> createState() => _ClaimPageState();
}

class _ClaimPageState extends ConsumerState<ClaimPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final claimState = ref.watch(claimProvider);

    ref.listen<ClaimState>(claimProvider, (previous, next) {
      if (next is ClaimSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カードのClaimが完了しました！')),
        );
        Navigator.of(context).pop();
      } else if (next is ClaimError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('カードをClaim'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'NFC名刺をClaimするには、メールアドレスを入力してください',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            if (!_isEmailSent) ...[
              EmailInputWidget(
                controller: _emailController,
                onSendOtp: () => _sendOtp(),
                isLoading: claimState is ClaimLoading,
              ),
            ] else ...[
              OTPInputWidget(
                controller: _otpController,
                onVerifyOtp: () => _verifyOtp(),
                onResendOtp: () => _sendOtp(),
                isLoading: claimState is ClaimLoading,
              ),
            ],
            
            const SizedBox(height: 24),
            
            if (claimState is ClaimLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void _sendOtp() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールアドレスを入力してください')),
      );
      return;
    }

    ref.read(claimProvider.notifier).startClaim(
      email: _emailController.text,
      cardId: widget.cardId,
    ).then((_) {
      setState(() {
        _isEmailSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTPをメールで送信しました')),
      );
    });
  }

  void _verifyOtp() {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTPを入力してください')),
      );
      return;
    }

    ref.read(claimProvider.notifier).verifyOtpAndClaim(
      email: _emailController.text,
      otp: _otpController.text,
      cardId: widget.cardId,
    );
  }
}


