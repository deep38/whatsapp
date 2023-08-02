import 'package:flutter/material.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';

// ignore: must_be_immutable
class WhatsAppTextField extends StatelessWidget {
  WhatsAppTextField({
    super.key,
    this.controller,
    // this.onChanged,
    this.validator,
    this.onValidationChange,
    this.maxLength = 25,
    this.initialValue,
  });

  final TextEditingController? controller;
  // final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final void Function(bool isValid)? onValidationChange;
  final int maxLength;
  final String? initialValue;

  late final ValueNotifier<String> _nameChangeNotifier = ValueNotifier(initialValue ?? controller?.text ?? "");


  bool _nameWasValid = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: initialValue,
            controller: controller,
            validator: validator ?? _nameValidator,
            autofocus: true,
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: _onChanged,
            textCapitalization: TextCapitalization.words,
            maxLength: maxLength,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              counter: ValueListenableBuilder(
                valueListenable: _nameChangeNotifier,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: const Offset(0, -30),
                    child:
                    Text(
                        value.isNotEmpty
                        ? "${maxLength - value.length}"
                        : "",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  );
                },
              ),
              errorStyle: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.red),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
            ),
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(WhatsAppIcons.emoji))
      ],
    );
  }

  void _onChanged(String name) {
    _nameChangeNotifier.value = name;

    if (_nameValidator(name) == null) {
      if (!_nameWasValid) {
        onValidationChange?.call(true);
        _nameWasValid = true;
      }
    } else {
      if (_nameWasValid) {
        onValidationChange?.call(false);
        _nameWasValid = false;
      }
    }
  }

  String? _nameValidator(String? name) {
    if (name == null || name.isEmpty) return "Name is required";

    return null;
  }
}
