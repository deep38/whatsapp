import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/utils/enums.dart';

class SearchOptionChips extends StatelessWidget {
  const SearchOptionChips({super.key, required this.optionList});

  final List<SearchOptionChip> optionList;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: optionList.map((option) => _buildOptionChip(context, option)).toList(),
    );
  }

  Widget _buildOptionChip(BuildContext context, SearchOptionChip option) {
    return ActionChip(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      padding:  const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: Colors.blueGrey.withOpacity(0.3),
      labelPadding: const EdgeInsets.only(right: 6),
      avatar: Icon(_getIcon(option), color: Theme.of(context).iconTheme.color,),
      onPressed: (){},
      labelStyle: Theme.of(context).textTheme.labelLarge,
      label: Text(
        option.name.substring(0, 1).toUpperCase() + option.name.substring(1),
      ),
    );
  }

  IconData _getIcon(SearchOptionChip option) => switch(option) {
    SearchOptionChip.unread => Icons.mark_unread_chat_alt_rounded,
    SearchOptionChip.photos => WhatsAppIcons.image,
    SearchOptionChip.videos => WhatsAppIcons.videocam_rounded,
    SearchOptionChip.links => WhatsAppIcons.link,
    SearchOptionChip.gifs => Icons.gif_box,
    SearchOptionChip.audio => WhatsAppIcons.audio,
    SearchOptionChip.documents => WhatsAppIcons.document,
    SearchOptionChip.polls => WhatsAppIcons.poll,
  };
}
