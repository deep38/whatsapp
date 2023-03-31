import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/database/table_helper.dart';
import 'package:whatsapp/data/database/tables/chat_table.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/firebase/chat_stream_loader.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/device_contacts/device_contact_page.dart';
import 'package:whatsapp/presentation/pages/home/chats/chat_list_tile.dart';
import 'package:whatsapp/presentation/providers/select_count_provider.dart';
import 'package:whatsapp/presentation/widgets/security_message.dart';
import 'package:whatsapp/utils/enums.dart';

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
  // final StreamController<QuerySnapshot<Map<String, dynamic>>> _chatStremController = StreamController();

  final GlobalKey<SliverAnimatedListState> _chatListKey = GlobalKey();

  final ValueNotifier<bool> _emptyListNotifier = ValueNotifier<bool>(true);

  // late bool _inSelectMode;
  List<Chat> _chats = [];

  int _pinnedMessages = 0;

  @override
  void initState() {
    super.initState();

    // _inSelectMode = widget.inSelectMode;
    // _chats = loadChats();
    // _chatStremController.stream.listen(_listenForNewChats);
    // _chatStremController.addStream(FirebaseChatStream.getChatsStream());
    debugPrint("SetAddChatCallback: ${widget.setAddChatCallback}");
    widget.setAddChatCallback?.call(_addChat);
    widget.setOnFabPressed(_showDeviceContacts);
    _listenForNewChats();
  }

  // void sendMessage() {
  //   if(_chats.isEmpty) return;
  //   CancelableOperation
  //   FirestoreHelper.sendMessage(_chats[0].id, Message(id: "", data: " Manual message", senderId: UserManager.uid ?? "", time: DateTime.now().microsecondsSinceEpoch, state: MessageState.sent).toMapWithoutId())
  //     .then((id) {
  //       debugPrint("Send Message In then");
  //     }
  //   ).onError((error, stackTrace)  { debugPrint("Send message In error: $error");return null;})
  //   .whenComplete(() { debugPrint("Send message In when complete");return null;})
  //   .timeout(const Duration(seconds: 5), onTimeout: );
  // }

  void _showDeviceContacts() async {
    Chat? chat = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => DeviceContactsPage()));
    debugPrint("Chat returned: $chat");
    if (chat != null) {
      if (_chats.isEmpty) {
        _emptyListNotifier.value = false;
      }
      int chatIndex;
      if ((chatIndex = _chats.indexWhere((c) => c.id == chat.id)) > -1) {
        if (_chats[chatIndex].messages.length < chat.messages.length) {
          _chats[chatIndex].messages = chat.messages;
          _onNewMessageSent(_chats[chatIndex], chatIndex);
        }
      } else {
        _chats.insert(_pinnedMessages, chat);
        _chatListKey.currentState?.insertItem(_pinnedMessages);
      }
    }
  }

  Future<List<Chat>> loadLocalChats() async {
    _chats = await _tableHelper.getAllChats();
    _emptyListNotifier.value = _chats.isEmpty;
    _chats.sort((a, b) {
      if (b.messages.isEmpty && a.messages.isEmpty) return 0;
      if (b.messages.isNotEmpty && a.messages.isEmpty) return 1;
      if (b.messages.isEmpty && a.messages.isNotEmpty) return -1;
      return b.messages.last.time.compareTo(a.messages.last.time);
    });
    // sendMessage();

    return _chats;
  }

  void _addChat(Chat chat) {
    debugPrint("Adding chat $chat");
    if (_chats.isEmpty) {
      _chats.add(chat);
      // _emptyListNotifier.value = false;
    } else {
      _chats.insert(_pinnedMessages, chat);
      _chatListKey.currentState?.insertItem(_pinnedMessages);
    }

    debugPrint("Added chat $chat");
  }

  void _listenForNewChats() {
    FirestoreHelper.getChatStream().listen(
      (QuerySnapshot<Map<String, dynamic>> data) {
        List<Chat> newChats = _loadChatsFromFirebaseData(data);
      },
    );
  }

  List<Chat> _loadChatsFromFirebaseData(QuerySnapshot<Map<String, dynamic>> data) {
    List<Chat> chats = [];

    for (var chatDoc in data.docs) {
      String id = chatDoc.id;
      Map<String, dynamic> data = chatDoc.data();
      List<String> userIds = data['users'];
      List<WhatsAppUser> users = FirestoreHelper.getUsersFromIds(userIds);
      ChatType type = ChatType.values.firstWhere((element) => element.name == data['type']);
      
      chats.add(Chat(id: id, users: users, messages: [], type: type));
    }
    return data.docs.map((chatSnapshot) => Chat.fromFirebaseMap(chatSnapshot.id, chatSnapshot.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        FutureBuilder(
            future: loadLocalChats(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildChats();
              } else if (snapshot.hasError) {
                return _buildChatLoadingError(snapshot);
              } else {
                return _buildChatLoading();
              }
            })
      ],
    );
  }

  SliverFillRemaining _buildEmptyChat() {
    return const SliverFillRemaining(
      child: Center(
        child: Text("There is no chat press button below to start new chat"),
      ),
    );
  }

  SliverFillRemaining _buildChatLoadingError(
      AsyncSnapshot<List<Chat>> snapshot) {
    return SliverFillRemaining(
      child: Center(
        child: Text("Error while loading chats: ${snapshot.error.toString()}"),
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

  Widget _buildChats() {
    return ValueListenableBuilder(
      valueListenable: _emptyListNotifier,
      builder: (context, value, child) => _chats.isEmpty
          ? _buildEmptyChat()
          : SliverAnimatedList(
              key: _chatListKey,
              initialItemCount: _chats.length,
              itemBuilder: (context, index, animation) => index < _chats.length
                  ? SizeTransition(
                      sizeFactor: animation,
                      child: ValueListenableBuilder(
                          valueListenable: widget.selectModeNotifier,
                          builder: (context, inSelectMode, child) {
                            if (!inSelectMode &&
                                widget.selectedChatList.isNotEmpty)
                              widget.selectedChatList.clear();
                            return ChatListTile(
                              key: Key(_chats[index].id),
                              chat: _chats[index],
                              onSelectToggle: _onSelectToggle,
                              onNewMessageSent: _onNewMessageSent,
                              selectModeNotifier: widget.selectModeNotifier,
                            );
                          }),
                    )
                  : const SecurityMessage(
                      securityFieldName: "personal messages"),
            ),
    );
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

  void addChat() {
    String id = generateRandomString(32);
    String number = "${9000000000 + Random().nextInt(999999999)}";
    String profileUrl = "#";
    List<Message> messages = [];

    _chats.insert(
        0,
        Chat(
            id: id,
            users: [
              WhatsAppUser(
                  uid: id,
                  phoneNo: number,
                  name: "Deep",
                  profileUrl: profileUrl)
            ],
            messages: messages,
            type: ChatType.onetoone));
    _emptyListNotifier.value = _chats.isEmpty;
    _chatListKey.currentState?.insertItem(0);

    _tableHelper
        .insertChat(_chats.first.toChatTableRow())
        .then((value) => debugPrint("Insert result code: $value"));
    // _currentChatIndex++;
  }

  void _onNewMessageSent(Chat chat, [int? index]) {
    if (_chats.isNotEmpty && chat != _chats[0]) {
      int i = index ?? _chats.indexOf(chat);
      _chats.remove(chat);
      _chatListKey.currentState?.removeItem(
          i, (context, animation) => ScaleTransition(scale: animation));
      _chats.insert(_pinnedMessages, chat);
      _chatListKey.currentState?.insertItem(_pinnedMessages);
    }
  }

  String generateRandomString(int length) {
    final random = Random();
    final charCodes = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(charCodes);
  }
}
