import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_button.dart';

class UrlEditWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSave;
  final bool isLoading;

  const UrlEditWidget({
    super.key,
    required this.controller,
    required this.onSave,
    required this.isLoading,
  });

  void _validateAndSave() {
    final url = controller.text.trim();
    
    if (url.isEmpty) {
      return; // 空の場合は何もしない（親でエラーハンドリング）
    }
    
    // URLの基本的なバリデーション
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // 自動的にhttps://を追加
      controller.text = 'https://$url';
    }
    
    onSave(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '現在のURL',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'リダイレクト先URL',
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'URLを更新',
              onPressed: isLoading ? null : () => _validateAndSave(),
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}


