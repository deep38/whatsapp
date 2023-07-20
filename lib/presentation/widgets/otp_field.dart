import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:whatsapp/presentation/widgets/processing_dialog.dart';

class OtpField extends StatelessWidget {
  final int length;
  final Function(String otp) onFilled;

  late final List<TextEditingController> _controllers = [];
  late final List<FocusNode> _focusNodes = [];
  String otp = "";

  OtpField({
    super.key,
    this.length = 6,
    required this.onFilled,
  }) {
    for (int fieldNo = 0; fieldNo < length; fieldNo++) {
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
                color: Theme.of(context).colorScheme.primary, width: 2,),),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i <= length; i++)
            i == length / 2
                ? const SizedBox(
                    width: 20,
                  )
                : _buildTextField(context, i < length / 2 ? i : i - 1)
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, int fieldNo) {
    debugPrint(
        "Creating text fieldNo: $fieldNo with controller ${_controllers[fieldNo]} and focusNode ${_focusNodes[fieldNo]}");
    return TextField(
      key: Key("Field_$fieldNo"),
      onChanged: (value) => _onInputChange(fieldNo, value),
      controller: _controllers[fieldNo],
      focusNode: _focusNodes[fieldNo],
      autofocus: fieldNo == 0,
      textInputAction:
          fieldNo < length - 1 ? TextInputAction.next : TextInputAction.done,
      keyboardType: TextInputType.number,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 24),
      decoration: InputDecoration(
        counterText: "",
        hintText: "\u2014",
        hintStyle: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        constraints: const BoxConstraints(maxWidth: 25),
      ),
      maxLength: 1,
    );
  }

  void _onInputChange(int fieldNo, String value) {
    if(_valid(value)) {
      _focusNodes[fieldNo].nextFocus();
    } else {
      _controllers[fieldNo].clear();
    }

    checkIfFilled();
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    debugPrint("Key pressed ${event.data}");
    if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
      int fieldNo = _focusNodes.indexOf(node);
      int clearIndex = _controllers[fieldNo].text == "" ? fieldNo - 1 : fieldNo;
      if (fieldNo > 0) {
        _controllers[clearIndex].clear();
        node.previousFocus();
      }
    } else if(_valid(event.character)) {
      int fieldNo = _focusNodes.indexOf(node);
      if (fieldNo < length - 1 && _controllers[fieldNo].text != "") {
        node.nextFocus();
        _controllers[fieldNo + 1].text = "${event.character}";
        checkIfFilled();
      }
    }
    return KeyEventResult.ignored;
  }

  void checkIfFilled() {
    otp = _getOtp();
    if(otp.length == length) {
      onFilled(otp);
    }
  }

  String _getOtp() {
    String otp = "";
    for (TextEditingController controller in _controllers) {
      otp += controller.text;
    }

    return otp;
  }

  bool _valid(String? value) {
    return value != null && value.contains(RegExp(r'[0-9]{1}'));
  }
}
