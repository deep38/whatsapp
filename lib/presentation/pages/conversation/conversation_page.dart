import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/database/table_helper.dart';
import 'package:whatsapp/data/database/tables/chat_table.dart';
import 'package:whatsapp/data/database/tables/chat_users_table.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/database/tables/users_table.dart';
import 'package:whatsapp/data/database/tables/waiting_message.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/helpers/conversation_helper.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/conversation/message_bubble.dart';
import 'package:whatsapp/presentation/pages/conversation/message_change_notifier.dart';
import 'package:whatsapp/presentation/pages/home/chats/chat_list_tab.dart';
import '../../../../utils/enums.dart';
import '../../../../utils/mapers/asset_images.dart';
import 'package:whatsapp/presentation/theme/theme.dart';
import 'package:whatsapp/presentation/widgets/animated_cross_scale.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';

class ConversationPage extends StatefulWidget {
  final Chat? chat;
  final WhatsAppUser? user;
  final ValueNotifier<Message?>? lastMessageChangeNotifier;

  const ConversationPage({
    super.key,
    this.chat,
    this.user,
    this.lastMessageChangeNotifier,
  }) : assert(chat != null || user != null);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  Chat? _chat;
  WhatsAppUser? _user;

  // final List<Message> _chat!.messages = [];
  final StreamController<String> _chatIdStreamController = StreamController();

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StreamController<QuerySnapshot<Map<String, dynamic>>>
      _messagestreamController = StreamController();
  final ValueNotifier<bool> _inputChangeNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _emptyListNotifier = ValueNotifier(true);

  final GlobalKey<AnimatedListState> _messageListKey = GlobalKey();

  bool _newChatCreated = false;

  // late Chat _chat;
  late ConversationHelper _conversationHelper;

  @override
  void initState() {
    super.initState();

    _chat = widget.chat;
    _user = widget.user ?? widget.chat?.users[0];
    _inputController.addListener(_onMessageChange);

    _conversationHelper = ConversationHelper(widget.chat, widget.user);
    // _loadMessages();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) { });
    _init();
  }

  void _init() async {
    if(_chat == null) {
      _chat = await _conversationHelper.initChatIfExists();
      _emptyListNotifier.value = _chat?.messages.isEmpty ?? true;
    } else {
      _emptyListNotifier.value = false;
    }
    
  }

  @override
  void dispose() {
    _inputController.removeListener(_onMessageChange);
    _inputController.dispose();
    _scrollController.dispose();
    _inputChangeNotifier.dispose();

    super.dispose();
  }

  // void _onMessagesChange(
  //     QuerySnapshot<Map<String, dynamic>> messageSnapshot) async {
  //   List<QueryDocumentSnapshot<Map<String, dynamic>>> messages =
  //       messageSnapshot.docs;
  //   debugPrint("MessageChange: Loading from firebase... ${messages.length}");
  //   for (int i = 0; i < messages.length; i++) {
  //     Message message =
  //         Message.fromFirebaseMap(messages[i].id, messages[i].data());
  //     if (message.senderId == UserManager.uid || _chat!.messages.contains(message))
  //       continue;
  //     debugPrint("MessageChange: Adding message ${message.data}");
  //     MessageState? state = message.state;
  //     debugPrint(
  //         "MessageChange: ${message.state} ${message.senderId} == ${widget.user.uid}");

  //     message.updateState(MessageState.viewed);
  //     _chat!.messages.add(message);
  //     _messageListKey.currentState?.insertItem(_chat!.messages.length - 1,
  //         duration: const Duration(milliseconds: 100));
  //     if (state != MessageState.viewed && message.senderId == widget.user.uid) {
  //       await FirestoreHelper.updateMessageState(
  //           _roomId!, message.id, MessageState.viewed.name);
  //     }
  //     // debugPrint("Message added");
  //     if (!(await _messageTable.exists(message.id))) {
  //       debugPrint("MessageChange: Adding message to database ${message.data}");
  //       _messageTable.insert(message.toMessageTableRow(_roomId!));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<WhatsAppComponents>();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          _onBack(context);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: Theme.of(context).colorScheme.surface,
            leading: _buildAppBarLeading(context),
            title: Text(
              _user!.name ?? _user!.phoneNo,
            ),
            actions: _buildAppBarActions(),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: colors?.chatScreenBackground,
                      image: DecorationImage(
                        opacity: Theme.of(context).brightness == Brightness.dark
                            ? 0.1
                            : 0.4,
                        isAntiAlias: true,
                        fit: BoxFit.cover,
                        image: const AssetImage(
                            AssetImages.default_chat_background),
                      )),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMessages(colors),
                    ),
                    _buildInputSection(context)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarLeading(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      customBorder: const StadiumBorder(),
      onTap: () => _onBack(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          ProfilePhoto(
              placeholder: const AssetImage(AssetImages.default_profile),
              image: NetworkImage("_chat.profileUrl"))
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
          onPressed: () {}, icon: const Icon(WhatsAppIcons.videocam_rounded)),
      IconButton(onPressed: () {}, icon: const Icon(WhatsAppIcons.call)),
      PopupMenuButton(itemBuilder: (context) => []),
    ];
  }

  Widget _buildMessages(WhatsAppComponents? colors) {
    return ValueListenableBuilder(
      valueListenable: _emptyListNotifier,
      builder: (context, value, child) => value
          ? const SizedBox()
          : AnimatedList(
              key: _messageListKey,
              controller: _scrollController,
              initialItemCount: _chat?.messages.length ?? 0,
              itemBuilder: (context, index, animation) {
                Message message = _chat!.messages[index];
                Color? chatBubbleColor;
                Color? touchedChatBubbleColor;
                bool isSent = message.senderId != widget.user!.uid;
                if (isSent) {
                  chatBubbleColor = colors?.chatSentBubbleColor;
                  touchedChatBubbleColor = colors?.touchedChatSentBubbleColor;
                } else {
                  chatBubbleColor = colors?.chatReceivedBubbleColor;
                  touchedChatBubbleColor =
                      colors?.touchedChatReceivedBubbleColor;
                }
                animation.addListener(() {
                  if (animation.status == AnimationStatus.forward) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.linear,
                    );
                  }
                });
                return ScaleTransition(
                  alignment: isSent ? Alignment.topRight : Alignment.topLeft,
                  scale: animation,
                  child: MessageBubble(
                    message: message,
                    roomId: _chat?.id,
                    chatIdStreamController:
                        _chat == null || _chat!.id.startsWith("UNSENT")
                            ? _chatIdStreamController
                            : null,
                    isSent: isSent,
                    color: chatBubbleColor,
                    touchedColor: touchedChatBubbleColor,
                    isOfPreviousMessageType: index > 0 &&
                        _chat!.messages[index - 1].senderId == message.senderId,
                  ),
                );
              }),
    );
  }

  Container _buildInputSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildMessageInput(context),
          const SizedBox(
            width: 6,
          ),
          _buildInputActionButton(),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(WhatsAppIcons.emoji),
            ),
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 5,
                style: Theme.of(context).textTheme.displaySmall,
                textCapitalization: TextCapitalization.sentences,
                controller: _inputController,
                onChanged: _onMessageChange,
                decoration: const InputDecoration(
                  hintText: "Message",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: Transform.flip(
                    flipX: true, child: const Icon(WhatsAppIcons.attach))),
            ValueListenableBuilder(
              valueListenable: _inputChangeNotifier,
              builder: (context, value, child) => AnimatedContainer(
                width: value ? 48 : 0,
                height: 48,
                duration: const Duration(milliseconds: 100),
                child: AnimatedOpacity(
                  opacity: value ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(WhatsAppIcons.camera_fill),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _buildInputActionButton() {
    return SizedBox(
      height: 50,
      child: AspectRatio(
        aspectRatio: 1,
        child: ValueListenableBuilder(
          valueListenable: _inputChangeNotifier,
          builder: (context, value, child) {
            return FloatingActionButton(
                onPressed: value ? _openMic : _send,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: AnimatedCrossScale(
                  firstChild: const Icon(
                    WhatsAppIcons.mic,
                    key: Key("Mic"),
                  ),
                  secondChild: const Icon(
                    WhatsAppIcons.send,
                    key: Key("Send"),
                  ),
                  crossFadeState: value
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 100),
                ));
          },
        ),
      ),
    );
  }

  void _onBack(BuildContext context) {
    Navigator.pop(context, _newChatCreated ? _chat : null);
  }

  void _send() async {
    Message message = Message(
      id: generateRandomString(20),
      senderId: UserManager.uid!,
      data: _inputController.text,
      time: DateTime.now().millisecondsSinceEpoch,
      state: MessageState.waiting,
    );

    _chat ??= await _conversationHelper.createNewChat();
    
    _chat!.messages.add(message);
    _messageListKey.currentState?.insertItem(_chat!.messages.length  - 1);
  }

  // void _onMessageSent(String id, Message message) async {
  //   await _waitingMessageTable.delete(message.id);
    // debugPrint("Message sent");
  //   message.setId(id);
  //   message.updateState(MessageState.sent);

  //   debugPrint("Message sent inserting in: with ${_chat?.id}");
  //   await _messageTable.insert(message.toMessageTableRow(_chat!.id));
  // }

  void _openMic() {}

  void _onMessageChange([String? value]) {
    _inputChangeNotifier.value =
        (value ?? _inputController.text).trim().isEmpty;
  }

  

  String generateRandomString(int length) {
    final random = Random();
    final charCodes = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(charCodes);
  }
}
