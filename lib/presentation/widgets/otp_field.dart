import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:whatsapp/presentation/widgets/processing_dialog.dart';

class OtpField extends StatelessWidget {
  final int length;
  final Function(String otp) onFilled;

  late final List<TextEditingController> _controllers = [];
  late final List<FocusNode> _focusNodes = [];

  OtpField({
    super.key,
    this.length = 6,
    required this.onFilled,
  }) {
    for(int fieldNo = 0; fieldNo < length; fieldNo++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode()..onKey = _onKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2
          )
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for(int i = 0; i <= length; i++)
            i == length / 2 ? 
              const SizedBox(width: 20,) : 
              _buildTextField(context, i < length / 2 ? i : i - 1)
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, int fieldNo) {
    return TextField(
      key: Key("Field_$fieldNo"),
      onChanged: (value) => _onInputChange(fieldNo, value),
      controller: _controllers[fieldNo],
      focusNode: _focusNodes[fieldNo],
      autofocus: fieldNo == 0,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 24),
      decoration: InputDecoration(
        counterText: "",
        hintText: "\u2014",
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          maxWidth: 25
        ),
      ),
      maxLength: 1,
    );
  }

  void _onInputChange(int fieldNo, String value) {
    if(fieldNo == 0 && value == "") return;

    if(fieldNo == length - 1 && _valid(value)) {
      onFilled(_getOtp());
      return;
    }

    if(value == "") _focusNodes[fieldNo].previousFocus();

    if(_valid(value)) {
      _focusNodes[fieldNo].nextFocus();
    } else {
      _controllers[fieldNo].clear();
    }
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    int fieldNo = _focusNodes.indexOf(node);
    if(event.isKeyPressed(LogicalKeyboardKey.backspace)) {
      if(fieldNo > 0 && _controllers[fieldNo].text == "") {
        _controllers[fieldNo - 1].text = "";
        node.previousFocus();
      }
    } else if(fieldNo != length - 1 && _valid(event.character) && _valid(_controllers[fieldNo].text)) {
      node.nextFocus();
      _controllers[fieldNo + 1].text = event.character ?? "";
      if(fieldNo == length - 2) onFilled(_getOtp());
    }
    return KeyEventResult.ignored;
  }

  String _getOtp() {
    String otp = "";
    for(TextEditingController controller in _controllers) {
      otp += controller.text;
    }

    return otp;
  }

  bool _valid(String? value) {
    return value != null && value.contains(RegExp(r'[0-9]{1}'));
  }
}