import 'package:flutter/material.dart';

class WhatsAppSearch extends StatefulWidget {
  final double? height;
  final Widget? leading;
  final Widget? trailing;
  final Function() onClose;
  final ValueNotifier<bool> visibilityNorifier;

  const WhatsAppSearch({
    super.key,
    this.height,
    required this.visibilityNorifier,
    required this.onClose,
    this.leading,
    this.trailing,
  });

  @override
  State<WhatsAppSearch> createState() => _WhatsAppSearchState();
}

class _WhatsAppSearchState extends State<WhatsAppSearch> {

  final TextEditingController _queryController = TextEditingController();
  final ValueNotifier<String> _queryChangeNotifier = ValueNotifier("");
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    widget.visibilityNorifier.addListener(_onVisibilityChange);
  }

  @override
  void dispose() {
    _queryChangeNotifier.dispose();

    widget.visibilityNorifier.removeListener(_onVisibilityChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  MediaQuery.of(context).size.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Theme.of(context).dialogTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                  color: Theme.of(context).shadowColor
                )
              ]
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    _clearQuery();
                    widget.onClose();
                  },
                  icon: const Icon(Icons.arrow_back_rounded)
                ),
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    focusNode: _focusNode,
                    onChanged: _onQueryChange,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      
                      hintText: "Search...",
      
                      border: InputBorder.none,
      
                      suffixIcon: ValueListenableBuilder(
                        valueListenable: _queryChangeNotifier,
                        builder: (context, query, child) {
                          return (query.isNotEmpty && child != null) ? child : SizedBox.fromSize(size: Size.zero,);
                        },
                        child: IconButton(
                          onPressed: _clearQuery,
                          icon: const Icon(Icons.clear)
                        ),
                      )
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }

  void _onQueryChange(String query) {
    _queryChangeNotifier.value = query;
  }

  void _onVisibilityChange() {
    bool isVisible = widget.visibilityNorifier.value;
    if(isVisible) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  void _clearQuery(){
    _queryController.text = "";
  }
}