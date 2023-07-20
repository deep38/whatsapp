import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/bloc/chatting/chats_bloc.dart';
import 'package:whatsapp/bloc/chatting/chats_event.dart';
import 'package:whatsapp/bloc/chatting/chats_state.dart';
import 'package:whatsapp/bloc/messages/messages_bloc.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/helpers/conversation_helper.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/data/repository/chats_repository.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/theme/theme.dart';
import 'package:whatsapp/presentation/widgets/animated_cross_scale.dart';
import 'package:whatsapp/presentation/widgets/message_bubble.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';

import '../../../../utils/enums.dart';
import '../../../../utils/mapers/asset_images.dart';

class ChattingPage extends StatefulWidget {
  final Chat? chat;
  final WhatsAppUser user;
  final ValueNotifier<Message?>? lastMessageChangeNotifier;

  const ChattingPage({
    super.key,
    this.chat,
    required this.user,
    this.lastMessageChangeNotifier,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  final GlobalKey<AnimatedListState> _messageListKey = GlobalKey();

  final TextEditingController inputController = TextEditingController();
  final ValueNotifier inputChangeNotifier = ValueNotifier<bool>(true);

  late final Chat _chat;

  // late final WhatsAppUser _user;

  bool _chatNotExists = true;
  bool _chatCreated = false;

  @override
  void initState() {
    super.initState();

    _initChat();
  }

  @override
  void dispose() {
    inputController.dispose();
    inputChangeNotifier.dispose();

    super.dispose();
  }

  void _initChat() {
    debugPrint("User is ${widget.user}");
    List<Chat> chatList = BlocProvider.of<ChattingBloc>(context).chatList;
    if (widget.chat != null) {
      _chat = widget.chat!;
      _chatNotExists = false;
      debugPrint("Chat is provided: $_chat");
    } else {
      debugPrint("Chatdoes not provided");
      for (final chat in chatList) {
        if (chat.participants.contains(widget.user) && chat.type == ChatType.onetoone) {
          _chat = chat;
          _chatNotExists = false;
          debugPrint("Chat exists and found: $_chat");
          break;
        }
      }

      if (_chatNotExists) {
        _chat = Chat(
          id: generateRandomString(16),
          participants: [widget.user],
          messages: List.empty(growable: true),
          type: ChatType.onetoone,
        );

        debugPrint("Chat not found, initialized to: $_chat");
      }
    }

    // _user = widget.user ??
    //     _chat.participants.firstWhere(
    //         (element) => element.phoneNo != UserManager.phoneNumber);

    debugPrint("User initialized to: ${widget.user}");
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<WhatsAppComponents>();
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          leading: _buildAppBarLeading(context),
          leadingWidth: 68,
          titleSpacing: 0,
          title: Text(widget.user.name ?? widget.user.phoneNo),
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
                      image:
                          const AssetImage(AssetImages.default_chat_background),
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
    );
  }

  Widget _buildAppBarLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        customBorder: const StadiumBorder(),
        onTap: _goBack,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
            ProfilePhoto(
                placeholder: const AssetImage(AssetImages.default_profile),
                image: NetworkImage(widget.user.profileUrl ?? "#"),)
          ],
        ),
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
    return BlocConsumer<ChattingBloc, ChattingState>(
            listenWhen: (previous, current) =>
                current is NewMessageState && current.chatId == _chat.id,
            buildWhen: (previous, current) => false,
            listener: (context, state) {
              if (state is NewMessageState) {
                debugPrint("New message ${state.message} ${_chat.messages}");
                // debugPrint("Current ")
                _messageListKey.currentState
                    ?.insertItem(_chat.messages.length - 1);
              }
            },
            builder: (context, state) {
              final messages = _chat.messages;
              return AnimatedList(
                key: _messageListKey,
                initialItemCount: messages.length,
                itemBuilder: (context, index, animation) {
                  bool isSent = messages[index].senderId == UserManager.uid;

                  return MessageBubble(
                    message: messages[index],
                    roomId: _chat.id,
                    color: isSent ? colors?.chatSentBubbleColor : colors?.chatReceivedBubbleColor,
                    touchedColor: isSent ? colors?.touchedChatSentBubbleColor : colors?.touchedChatReceivedBubbleColor,
                  );
                },
              );
            });
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
                controller: inputController,
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
                flipX: true,
                child: const Icon(WhatsAppIcons.attach),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: inputChangeNotifier,
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
          valueListenable: inputChangeNotifier,
          builder: (context, value, child) {
            return FloatingActionButton(
                onPressed: value ? _openMic : _send,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
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

  // void _onBack(BuildContext context) {
  //   Navigator.pop(context, _newChatCreated ? _chat : null);
  // }

  void _send() async {
    debugPrint("Trying to send message....");
    Message message = Message(
      id: generateRandomString(20),
      senderId: UserManager.uid!,
      data: inputController.text,
      time: DateTime.now().millisecondsSinceEpoch,
      status: MessageStatus.waiting,
    );
    debugPrint("Message created....: $message");
    inputController.clear();

    if(_chatNotExists) {
      BlocProvider.of<ChattingBloc>(context).add(NewLocalChatEvent(_chat, message));
      _chatCreated = true;
      _chatNotExists = false;
    } else {
      

    BlocProvider.of<ChattingBloc>(context)
        .add(NewLocalMessageEvent(_chat.id, message));
    }
    // _chat ??= await _conversationHelper.createNewChat();

    // _chat!.messages.add(message);
    // _messageListKey.currentState?.insertItem(_chat!.messages.length - 1);
  }

  void _goBack() {
    Navigator.pop(context, _chatCreated);
  }

  void _openMic() {}

  void _onMessageChange([String? value]) {
    inputChangeNotifier.value = (value ?? inputController.text).trim().isEmpty;
  }

  String generateRandomString(int length) {
    final random = Random();
    final charCodes = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(charCodes);
  }
}
