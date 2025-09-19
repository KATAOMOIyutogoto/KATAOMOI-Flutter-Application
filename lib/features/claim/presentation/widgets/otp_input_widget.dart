import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_button.dart';

class OTPInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onVerifyOtp;
  final VoidCallback onResendOtp;
  final bool isLoading;

  const OTPInputWidget({
    super.key,
    required this.controller,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'OTPコード',
            hintText: '6桁のコードを入力',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.security),
          ),
          enabled: !isLoading,
          maxLength: 6,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'OTPを確認してClaim',
          onPressed: isLoading ? null : onVerifyOtp,
          isLoading: isLoading,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isLoading ? null : onResendOtp,
          child: const Text('OTPを再送信'),
        ),
      ],
    );
  }
}


