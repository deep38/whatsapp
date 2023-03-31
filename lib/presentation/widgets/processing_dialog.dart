import 'package:flutter/material.dart';

class ProcessingDialog extends StatelessWidget {
  final String message;
  const ProcessingDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
          Text(message, style: Theme.of(context).textTheme.bodyMedium,)
        ],
      ),
    );
  }
}