import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/bloc/chatting/chats_bloc.dart';
import 'package:whatsapp/bloc/chatting/chats_state.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/presentation/pages/chatting/chatting_page.dart';
import 'package:whatsapp/presentation/pages/profile/profile_photo/profile_photo_mini.dart';
import 'package:whatsapp/presentation/pages/profile/profile_photo/profile_photo_page.dart';
import 'package:whatsapp/presentation/widgets/list_tile.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';
import 'package:whatsapp/presentation/widgets/unread_count_indicator.dart';
import 'package:whatsapp/utils/extensions.dart';
import 'package:whatsapp/utils/global.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class ChatListTile extends StatefulWidget {
  final WhatsAppUser user;
  final Chat chat;
  final ValueNotifier selectModeNotifier;
  final Function(bool, Chat) onSelectToggle;
  final ValueNotifier<int> unreadChatsCountNotifier;

  const ChatListTile({
    super.key,
    required this.user,
    required this.chat,
    required this.onSelectToggle,
    required this.selectModeNotifier,
    required this.unreadChatsCountNotifier,
  });

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  bool _selected = false;
  final ValueNotifier<int> _unreadMessageCountNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _unreadMessageCountNotifier.value = 0;
    return ValueListenableBuilder(
        valueListenable: widget.selectModeNotifier,
        builder: (context, inSelectMode, child) {
          if (!inSelectMode && _selected) _selected = false;

          return WhatsAppListTile(
            selected: _selected,
            onTap: inSelectMode ? _toggleSelect : _openConversation,
            onLongPress: _toggleSelect,
            leading: Hero(
              tag: widget.user.phoneNo,
              child: ProfilePhoto(
                onTap: () => navigateWithoutTransition(
                  context,
                  ProfilePhotoPage(
                    user: widget.user,
                  ),
                ),
                placeholderPath: AssetImages.default_profile,
                imageUrl: widget.user.photoUrl ?? "#",
                url: widget.user.photoUrl,
              ),
            ),
            title: Text(widget.user.name ?? widget.user.phoneNo),
            subtitle: BlocBuilder<ChattingBloc, ChattingState>(
              buildWhen: (previous, current) => current is NewMessageState,
              builder: (context, state) {
                if (state is NewMessageState) {
                  // debugPrint("In widget message updated: ${state.message.data} ${state.message.status}.............");
                  if (state.message.senderId == UserManager.uid) {
                    _unreadMessageCountNotifier.value = 0;
                    // widget.unreadChatsCountNotifier.value--;
                  } else {
                    _unreadMessageCountNotifier.value++;
                    // if(_unreadMessageCountNotifier.value == 1) {
                    //   widget.unreadChatsCountNotifier.value++;
                    // }
                  }
                  return _buildSubtitle(state.message);
                } else if (widget.chat.messages.isNotEmpty) {
                  return _buildSubtitle(widget.chat.messages.last);
                } else {
                  return const SizedBox();
                }
              },
            ),
            trailingText: BlocBuilder<ChattingBloc, ChattingState>(
                buildWhen: (previous, current) => current is NewMessageState,
                builder: (context, state) {
                  if (state is NewMessageState) {
                    final date =
                        DateTime.fromMillisecondsSinceEpoch(state.message.time);
                    return Text(
                      date.describeTime(),
                      overflow: TextOverflow.ellipsis,
                    );
                  } else if (widget.chat.messages.isNotEmpty) {
                    final date = DateTime.fromMillisecondsSinceEpoch(
                        widget.chat.messages.last.time);

                    return Text(
                      date.describeTime(),
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return const SizedBox();
                }),
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

  Widget _buildSubtitle(Message message) {
    debugPrint(
        "New or message updated: ${message.data} ${message.status}.............");
    {
      return Row(
        children: [
          if (message.senderId == UserManager.uid) ...[
            BlocBuilder<ChattingBloc, ChattingState>(
              buildWhen: (previous, current) =>
                  current is MessageStatusUpdateState &&
                  current.message.id == widget.chat.messages.last.id,
              builder: (context, state) {
                if (state is MessageStatusUpdateState) {
                  debugPrint(
                      "In widget message updated: ${state.status}.............");
                  return buildMessageStatusIcon(state.status);
                } else {
                  return buildMessageStatusIcon(
                      widget.chat.messages.last.status);
                }
              },
            ),
            const SizedBox(
              width: 2,
            )
          ],
          Expanded(
              child: Text(
            message.data,
          )),
          ValueListenableBuilder(
            valueListenable: _unreadMessageCountNotifier,
            builder: (context, value, child) => value > 0
                ? UnreadCountIndicator(
                    text: "$value",
                  )
                : const SizedBox(),
          ),
        ],
      );
    }
  }

  void _openConversation() {
    _unreadMessageCountNotifier.value = 0;
    // widget.unreadChatsCountNotifier.value--;

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: BlocProvider.of<ChattingBloc>(context),
          child: ChattingPage(
            user: widget.user,
            chat: widget.chat,
          ),
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
