import 'package:flutter/material.dart';
import '../../../utils/global.dart';

class ThemeOptions extends StatefulWidget {
  const ThemeOptions({
    super.key,
    required this.onOptionChange,
  });

  final Function(ThemeMode) onOptionChange;

  @override
  State<ThemeOptions> createState() => _ThemeOptionsState();
}

class _ThemeOptionsState extends State<ThemeOptions> {
  final _tileColor = Colors.transparent;
  ThemeMode _selectedThemeMode = themeMode;

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          tileColor: _tileColor,
          title: const Text("System default"),
          value: ThemeMode.system, 
          groupValue: _selectedThemeMode, 
          onChanged: _onOptionChange,
        ),
        RadioListTile(
          tileColor: _tileColor,
          title: const Text("Light"),
          value: ThemeMode.light, 
          groupValue: _selectedThemeMode, 
          onChanged: _onOptionChange,
        ),
        RadioListTile(
          tileColor: _tileColor,
          title: const Text("Dark"),
          value: ThemeMode.dark,
          groupValue: _selectedThemeMode, 
          onChanged: _onOptionChange,
        ),
      ],
    );
  }

  void _onOptionChange(ThemeMode? themeMode) {
    _selectedThemeMode = themeMode ?? _selectedThemeMode;
    widget.onOptionChange(_selectedThemeMode);
    setState(() {
      
    });
  }
}