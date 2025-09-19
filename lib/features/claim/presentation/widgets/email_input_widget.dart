import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_button.dart';

class EmailInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendOtp;
  final bool isLoading;

  const EmailInputWidget({
    super.key,
    required this.controller,
    required this.onSendOtp,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'メールアドレス',
            hintText: 'example@email.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'OTPを送信',
          onPressed: isLoading ? null : onSendOtp,
          isLoading: isLoading,
        ),
      ],
    );
  }
}


