import 'package:flutter/material.dart';

class EditInfoBottomSheet extends StatelessWidget {
  const EditInfoBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.onCancel,
    this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(
            height: 16,
          ),
          child,
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text(
                  "Cancel",
                ),
              ),
              TextButton(
                onPressed: onSave,
                child: const Text(
                  "Save",
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
