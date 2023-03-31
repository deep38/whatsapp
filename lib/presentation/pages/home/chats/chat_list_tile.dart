import 'package:flutter/material.dart';
import 'package:whatsapp/data/database/tables/chat_table.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/info.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/conversation/conversation_page.dart';
import 'package:whatsapp/utils/global.dart';
import '../../../../../utils/mapers/asset_images.dart';
import 'package:whatsapp/presentation/widgets/list_tile.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';

class ChatListTile extends StatefulWidget {
  final Chat chat;
  final ValueNotifier selectModeNotifier;
  final Function(bool, Chat) onSelectToggle;
  final Function(Chat) onNewMessageSent;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.onSelectToggle,
    required this.onNewMessageSent,
    required this.selectModeNotifier,
  });

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  late WhatsAppUser _whatsAppUser;
  late ValueNotifier<Message?> _lastMessageChangeNotifier;

  bool _selected = false;

  @override
  void initState() {
    super.initState();

    _lastMessageChangeNotifier = ValueNotifier(
        widget.chat.messages.isNotEmpty ? widget.chat.messages.last : null);
    _lastMessageChangeNotifier
        .addListener((() => widget.onNewMessageSent(widget.chat)));

    assert(widget.chat.users.isNotEmpty);
    _whatsAppUser = widget.chat.users[0];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.selectModeNotifier,
        builder: (context, inSelectMode, child) {
          if (!inSelectMode && _selected) _selected = false;

          return WhatsAppListTile(
            selected: _selected,
            onTap: inSelectMode ? _toggleSelect : _openConversation,
            onLongPress: _toggleSelect,
            leading: ProfilePhoto(
              placeholder: const AssetImage(AssetImages.default_profile),
              image: NetworkImage(_whatsAppUser.profileUrl ?? "#"),
            ),
            title: Text(_whatsAppUser.phoneNo),
            subtitle: ValueListenableBuilder(
              valueListenable: _lastMessageChangeNotifier,
              builder: (context, message, child) => message != null
                  ? Text(message.data)
                  : SizedBox.fromSize(
                      size: Size.zero,
                    ),
            ),
            trailingText: ValueListenableBuilder(
                valueListenable: _lastMessageChangeNotifier,
                builder: (context, message, child) => message != null
                    ? Text(
                        "${message.time}",
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox.fromSize(
                        size: Size.zero,
                      )),
            trailingIcons: const [
              // if (widget.chat.isNotificationMute)
              //   const Icon(
              //     WhatsAppIcons.mute,
              //     size: 18,
              //   ),
              // if (widget.chat.isPinned)
              //   const Icon(
              //     WhatsAppIcons.pin,
              //     size: 18,
              //   ),
            ],
          );
        });
  }

  void _openConversation() {
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          user: _whatsAppUser,
          chat: widget.chat,
          lastMessageChangeNotifier: _lastMessageChangeNotifier,
        ),
      ),
    );
  }

  void _toggleSelect() {
    _selected = !_selected;
    widget.onSelectToggle(_selected, widget.chat);
    setState(() {});
  }
}
