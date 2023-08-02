import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/bloc/chatting/chats_bloc.dart';
import 'package:whatsapp/bloc/chatting/chats_event.dart';
import 'package:whatsapp/bloc/chatting/chats_state.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
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
  final ScrollController _messageListScrollController = ScrollController();
  final ValueNotifier _showScrollDownNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _selectModeChangeNotifier = ValueNotifier(false);

  final TextEditingController inputController = TextEditingController();
  final ValueNotifier<bool> inputChangeNotifier = ValueNotifier(true);

  final List<Message> _selectedMessages = [];

  late final Chat _chat;

  // late final WhatsAppUser _user;

  bool _chatNotExists = true;
  bool _chatCreated = false;

  @override
  void initState() {
    super.initState();
    _initChat();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _messageListScrollController
          .jumpTo(_messageListScrollController.position.maxScrollExtent + 105);
    });

    _messageListScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    inputController.dispose();
    inputChangeNotifier.dispose();
    _messageListScrollController.removeListener(_scrollListener);
    _messageListScrollController.dispose();

    super.dispose();
  }

  void _scrollListener() {
    _showScrollDownNotifier.value =
        _messageListScrollController.position.maxScrollExtent -
                _messageListScrollController.offset >
            100;
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
        if (chat.participants.indexWhere((p) => p.id == widget.user.id) != -1 &&
            chat.type == ChatType.onetoone) {
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
    final colors = Theme.of(context).extension<WhatsAppThemeComponents>();
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            surfaceTintColor: Theme.of(context).colorScheme.surface,
            leading: _buildAppBarLeading(context),
            leadingWidth: 68,
            titleSpacing: 0,
            title: _buildAppBarTitle(context),
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: Colors.white,
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
              Column(
                children: [
                  Expanded(
                    child: _buildMessages(colors),
                  ),
                  _buildInputSection(context)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _selectModeChangeNotifier,
      builder: (context, inSelectMode, child) => inSelectMode
          ? Text(
              "1",
              style: Theme.of(context).listTileTheme.titleTextStyle,
            )
          : ListTile(
              contentPadding: EdgeInsets.zero,
              tileColor: Theme.of(context).colorScheme.surface,
              title: Text(widget.user.name ?? widget.user.phoneNo),
              subtitle: widget.user.lastSeen != null
                  ? Text("last seen ${widget.user.lastSeen}")
                  : null,
              onTap: () {},
            ),
    );
  }

  Widget _buildAppBarLeading(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _selectModeChangeNotifier,
      builder: (context, inSelectMode, child) => inSelectMode
          ? IconButton(
              onPressed: _closeSelectMode,
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            )
          : Padding(
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
                      placeholderPath: AssetImages.default_profile,
                      imageUrl: widget.user.photoUrl ?? "#",
                    )
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return <Widget>[
      _buildAction(WhatsAppIcons.call, () { }, Icons.delete_rounded, _deleteSelectedMessages),
      _buildAction(WhatsAppIcons.videocam_rounded, () { }, WhatsAppIcons.forward, () { }),
      PopupMenuButton(itemBuilder: (context) => []),
    ];
  }

  Widget _buildAction(IconData iconData, VoidCallback onPressed, IconData selectModeIconData, VoidCallback selectModeOnPressed) {
    return ValueListenableBuilder(
      valueListenable: _selectModeChangeNotifier,
      builder: (context, inSelectMode, child) => IconButton(
          onPressed: inSelectMode ? selectModeOnPressed : onPressed,
          icon: Icon(
            inSelectMode ? selectModeIconData : iconData,
            color: Colors.white,
          ),
        ),
    );
      
  }

  Widget _buildMessages(WhatsAppThemeComponents? colors) {
    return Stack(
      children: [
        BlocConsumer<ChattingBloc, ChattingState>(
            listenWhen: (previous, current) =>
                current is NewMessageState && current.chat.id == _chat.id,
            buildWhen: (previous, current) => false,
            listener: (context, state) {
              if (state is NewMessageState) {
                //debugPrint(
                //"Chatting: New message ${state.message} ${state.chat} $_chat");
                if (_chat.messages.length != state.chat.messages.length) {
                  _chat = state.chat;
                }
                // debugPrint("Current ")
                // debugPrint("Chatting: In chatting page Chat is $_chat");
                // debugPrint(
                //     "Chatting: Messages in chat: ${_chat.messages.length}");
                _messageListKey.currentState
                    ?.insertItem(_chat.messages.length - 1);

                Future.delayed(const Duration(milliseconds: 100), () {
                  _scrollDown();
                  // _messageListScrollController.animateTo(
                  //   _messageListScrollController.position.maxScrollExtent,
                  //   duration: const Duration(milliseconds: 200),
                  //   curve: Curves.ease,
                  // );
                });
              }
            },
            builder: (context, state) {
              final messages = _chat.messages;
              // debugPrint(
              //     "ChattingBloc .........In page printing messages of chat id: ${_chat.id}...........");
              // for (Message message in messages) {
              //   debugPrint(
              //       "ChattingBloc ${message.id}, ${message.data}, ${message.status}");
              // }
              return Scrollbar(
                controller: _messageListScrollController,
                child: ValueListenableBuilder(
                  valueListenable: _selectModeChangeNotifier,
                  builder: (context, inSelectMode, child) => AnimatedList(
                    key: _messageListKey,
                    controller: _messageListScrollController,
                    initialItemCount: messages.length,
                    itemBuilder: (context, index, animation) {
                      bool isSent = messages[index].senderId == UserManager.uid;
                      // debugPrint("Building message $index ${messages[index].data}");
                      return MessageBubble(
                        message: messages[index],
                        roomId: _chat.id,
                        inSelectMode: inSelectMode,
                        onSelectToggle: _onMessageSelectToggle,
                        color: isSent
                            ? colors?.chatSentBubbleColor
                            : colors?.chatReceivedBubbleColor,
                        touchedColor: isSent
                            ? colors?.touchedChatSentBubbleColor
                            : colors?.touchedChatReceivedBubbleColor,
                        isOfPreviousMessageType: index != 0 &&
                            messages[index - 1].senderId ==
                                messages[index].senderId &&
                            _isOnSameDay(
                                messages[index - 1].time, messages[index].time),
                        onPrviousMessageDay: index != 0 &&
                            _isOnSameDay(
                                messages[index - 1].time, messages[index].time),
                      );
                    },
                  ),
                ),
              );
            }),
        ValueListenableBuilder(
          valueListenable: _showScrollDownNotifier,
          builder: (context, value, child) => Positioned(
            bottom: 8,
            right: 8,
            child: Visibility(
              visible: value,
              child: FloatingActionButton.small(
                tooltip: "Scroll down",
                foregroundColor: Theme.of(context).iconTheme.color,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                onPressed: _scrollDown,
                child: const Icon(
                  Icons.keyboard_double_arrow_down_rounded,
                  // color: ,
                ),
              ),
            ),
            //   child: Container(
            //     padding: const EdgeInsets.all(4.0),
            //     decoration: BoxDecoration(
            //       color: Theme.of(context).colorScheme.surface,
            //       borderRadius: BorderRadius.circular(18)
            //     ),

            //     child: const Icon(Icons.keyboard_double_arrow_down_rounded),
            //   )
          ),
        )
      ],
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

  void _scrollDown() {
    debugPrint(
        "Messages: ${_messageListScrollController.position.maxScrollExtent - _messageListScrollController.offset}");
    _messageListScrollController //.jumpTo(_messageListScrollController.position.maxScrollExtent);
        .animateTo(
      _messageListScrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _send() async {
    // debugPrint("Trying to send message....");
    Message message = Message(
      id: generateRandomString(20),
      senderId: UserManager.uid!,
      data: inputController.text.trim(),
      time: DateTime.now().millisecondsSinceEpoch,
      status: MessageStatus.waiting,
    );
    // debugPrint("Message created....: $message");
    inputController.clear();
    _onMessageChange();

    if (_chatNotExists) {
      _chatCreated = true;
      _chatNotExists = false;
      BlocProvider.of<ChattingBloc>(context)
          .add(NewLocalChatEvent(_chat, message));
    } else {
      BlocProvider.of<ChattingBloc>(context)
          .add(NewLocalMessageEvent(_chat.id, message));
    }

    // debugPrint("Chatting: In chatting page Chat is $_chat");
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

  bool _isOnSameDay(int time1, int time2) {
    final date1 = DateTime.fromMillisecondsSinceEpoch(time1);
    final date2 = DateTime.fromMillisecondsSinceEpoch(time2);

    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  void _onMessageSelectToggle(bool selected, Message message) {
    if (selected) {
      _selectedMessages.add(message);
    } else {
      _selectedMessages.remove(message);
    }

    //* Set select mode on if not on already.
    if (_selectedMessages.isEmpty && _selectModeChangeNotifier.value) {
      _selectModeChangeNotifier.value = false;
    }

    //* Turn off select mode if it is on and no items selected.
    if (_selectedMessages.isNotEmpty && !_selectModeChangeNotifier.value) {
      _selectModeChangeNotifier.value = true;
    }
  }

  void _closeSelectMode() {
    _selectModeChangeNotifier.value = false;
    _selectedMessages.clear();
  }

  void _deleteSelectedMessages() async {
    for (var message in _selectedMessages) {
      int index = _chat.messages.indexOf(message);
      _chat.messages.removeAt(index);
      _messageListKey.currentState?.removeItem(index, (context, animation) => const SizedBox(), duration: Duration.zero);
    }
    _closeSelectMode();
    await MessageTable().deleteMessages(_selectedMessages.map((e) => e.id).toList());
  }

  String generateRandomString(int length) {
    final random = Random();
    final charCodes = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(charCodes);
  }
}
