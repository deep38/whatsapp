import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/bloc/chatting/chats_bloc.dart';
import 'package:whatsapp/bloc/chatting/chats_event.dart';
import 'package:whatsapp/bloc/chatting/chats_state.dart';
import 'package:whatsapp/data/database/table_helper.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/firebase/streams/chat_stream.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/data/repository/chats_repository.dart';
import 'package:whatsapp/presentation/pages/chatting/chatting_page.dart';
import 'package:whatsapp/presentation/pages/device_contacts/device_contact_page.dart';
import 'package:whatsapp/presentation/providers/select_count_provider.dart';
import 'package:whatsapp/presentation/widgets/chat_list_tile.dart';
import 'package:whatsapp/presentation/widgets/list_tile.dart';
import 'package:whatsapp/presentation/widgets/security_message.dart';
import 'package:whatsapp/utils/enums.dart';
import 'package:whatsapp/utils/global.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class ChatList extends StatefulWidget {
  final List<Chat> selectedChatList;
  final Function(bool) toggleSelectMode;
  final Function(Function(Chat))? setAddChatCallback;
  final SelectCountProvider selectCountProvider;
  final ValueNotifier<bool> selectModeNotifier;
  final Function(Function()) setOnFabPressed;

  const ChatList({
    super.key,
    required this.selectedChatList,
    required this.toggleSelectMode,
    required this.selectCountProvider,
    required this.selectModeNotifier,
    required this.setOnFabPressed,
    this.setAddChatCallback,
  });

  @override
  State<ChatList> createState() => ChatListState();
}

class ChatListState extends State<ChatList> {
  final GlobalKey<SliverAnimatedListState> _chatListKey = GlobalKey();
  late BuildContext blocContext;

  int _pinnedMessages = 0;
  int i = 1;

  @override
  void initState() {
    super.initState();

    // widget.setAddChatCallback?.call(_addChat);
    widget.setOnFabPressed(_openDeviceContacts);
  }

  void _openDeviceContacts() async {
    bool? newChatCreated = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<ChattingBloc>(blocContext),
          child: const DeviceContactsPage(),
        ),
      ),
    );

    if(newChatCreated != null && newChatCreated) {
      // debugPrint("New chat created");
      // if(_chatListKey.currentState != null) {
      //   _chatListKey.currentState?.insertItem(0);
      //   debugPrint("State found inserted.");

      // } else {
      //   debugPrint("state not found seted.");
      //   setState(() {
          
      //   });
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        RepositoryProvider(
          create: (context) => ChatRepository(),
          child: BlocProvider(
            create: (context) =>
                ChattingBloc(RepositoryProvider.of<ChatRepository>(context))
                  ..add(LoadChatsEvent()),
            child: BlocConsumer<ChattingBloc, ChattingState>(
                buildWhen: (previous, current) => current is ChatsLoadedState,
                listenWhen: (previous, current) => current is NewChatState,
                listener: (context, state) {
                  if (state is NewChatState) {
                    if(_chatListKey.currentState == null) {
                      setState(() {});
                    } else {
                      _rearangeChats(0, state.currentIndex);
                    }
                  }
                },
                builder: (context, state) {
                  // debugPrint("Load state : ${BlocProvider.of<ChattingBloc>(context)}");
                  blocContext = context;
                  widget.setOnFabPressed(_openDeviceContacts);
                  if (state is ChatsLoadedState) {
                    List<Chat> chats = state.chatList;
                    debugPrint("$chats");
                    return chats.isNotEmpty
                        ? SliverAnimatedList(
                            key: _chatListKey,
                            initialItemCount: chats.length,
                            itemBuilder: (context, index, animation) {
                              debugPrint("${chats[index]}");
                            final user = chats[index].participants.firstWhere((e) => e.id != UserManager.uid);
                              return  AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) => SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.vertical,
                                child: Opacity(
                                  opacity: animation.value,
                                  child: WhatsAppListTile(
                                    onTap: () => navigateTo(
                                      context,
                                      BlocProvider.value(
                                        value: BlocProvider.of<ChattingBloc>(
                                            context),
                                        child: ChattingPage(
                                          chat: chats[index],
                                          user: user,
                                        ),
                                      ),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blueGrey,
                                      foregroundImage: _getProfielPhoto(user.profileUrl),
                                    ),
                                    title: Text(
                                            user.name
                                            ?? user.phoneNo),
                                  ),
                                ),
                              ),
                            );
                            }
                          )
                        : _buildEmptyChat();
                  } else if (state is ChatsLoadFailedState) {
                    return _buildChatLoadingError(state.error);
                  } else {
                    return _buildChatLoading();
                  }
                }),
          ),
        )
      ],
    );
  }

  ImageProvider _getProfielPhoto(String? url) {
    if(url != null) {
      return NetworkImage(url);
    } else {
      return const AssetImage(AssetImages.default_profile);
    }
  }


  SliverFillRemaining _buildEmptyChat() {
    return const SliverFillRemaining(
      child: Center(
        child: Icon(
          Icons.accessibility_new_rounded,
          size: 100,
        ),
      ),
    );
  }

  SliverFillRemaining _buildChatLoadingError(String error) {
    return SliverFillRemaining(
      child: Center(
        child: Text("Error while loading chats: $error"),
      ),
    );
  }

  SliverFillRemaining _buildChatLoading() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  void _rearangeChats(int to, [int? from]) {
    if (from != null) {
      _chatListKey.currentState?.removeItem(from, (context, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            child: Opacity(
              opacity: animation.value,
              child: const WhatsAppListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  foregroundImage: AssetImage(AssetImages.default_profile),
                ),
                title: Text(""),
              ),
            ),
          ),
        );
      });
    }

    _chatListKey.currentState?.insertItem(to);
  }

  void _onSelectToggle(bool select, Chat chat) {
    debugPrint("Chat toggled: $chat");
    if (select) {
      widget.selectedChatList.add(chat);
      if (!widget.selectModeNotifier.value) {
        widget.selectModeNotifier.value = true;
      }
      widget.selectCountProvider.setCount(widget.selectCountProvider.count + 1);
    } else {
      widget.selectedChatList.remove(chat);
      widget.selectCountProvider.setCount(widget.selectCountProvider.count - 1);
      if (widget.selectCountProvider.count <= 0 &&
          widget.selectModeNotifier.value) {
        widget.selectModeNotifier.value = false;
      }
    }
  }

  // void addChat() {
  //   String id = generateRandomString(32);
  //   String number = "${9000000000 + Random().nextInt(999999999)}";
  //   String profileUrl = "#";
  //   List<Message> messages = [];

  //   _chats.insert(
  //       0,
  //       Chat(
  //           id: id,
  //           participants: [
  //             WhatsAppUser(
  //               id: id,
  //               phoneNo: number,
  //               name: "Deep",
  //               profileUrl: profileUrl,
  //               about: "",
  //               lastSeen: 0,
  //               status: UserStatus.offline,
  //             )
  //           ],
  //           messages: messages,
  //           type: ChatType.onetoone));
  //   _emptyListNotifier.value = _chats.isEmpty;
  //   _chatListKey.currentState?.insertItem(0);

  //   _tableHelper
  //       .insertChat(_chats.first.toMapForStore())
  //       .then((value) => debugPrint("Insert result code: $value"));
  //   // _currentChatIndex++;
  // }

  // void _onNewMessageSent(Chat chat, [int? index]) {
  //   if (_chats.isNotEmpty && chat != _chats[0]) {
  //     int i = index ?? _chats.indexOf(chat);
  //     _chats.remove(chat);
  //     _chatListKey.currentState?.removeItem(
  //         i, (context, animation) => ScaleTransition(scale: animation));
  //     _chats.insert(_pinnedMessages, chat);
  //     _chatListKey.currentState?.insertItem(_pinnedMessages);
  //   }
  // }

  String generateRandomString(int length) {
    final random = Random();
    final charCodes = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(charCodes);
  }
}
