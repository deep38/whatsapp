import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils/global.dart';
import 'package:whatsapp/presentation/widgets/list_tile.dart';

class WhatsAppSearchDelegate<T> extends SearchDelegate<String> {

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
    fontSize: 17
  );


  @override
  PreferredSizeWidget? buildBottom(BuildContext context) {
    return PreferredSize(
      child: SizedBox(
        height: 100,
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          children: [
            ActionChip(onPressed: () {
            }, label: Text("Unread"), avatar: Icon(Icons.mark_chat_unread_rounded),)
          ],
        ),
      ),
      preferredSize: Size.fromHeight(100));
  }
  
  @override
  ThemeData appBarTheme(BuildContext context) {
    
    return super.appBarTheme(context).copyWith(
      canvasColor: Colors.transparent,

    );
  }
  @override
  String? get searchFieldLabel => "Search...";
  
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = "",
        icon: const Icon(Icons.close)
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ""),
      icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _results();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }

  @override
  void showSuggestions(BuildContext context) {
    
  }

  Widget _results() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) =>
        WhatsAppListTile(leading: Container(), title: Text("Result $index"))
    );
  }
}