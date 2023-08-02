import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/bloc/chatting/chats_bloc.dart';
import 'package:whatsapp/bloc/chatting/chats_event.dart';
import 'package:whatsapp/bloc/chatting/chats_state.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/presentation/theme/theme.dart';
import 'package:whatsapp/presentation/widgets/time_stamped_chat_message.dart';
import 'package:whatsapp/utils/enums.dart';
import 'package:whatsapp/utils/extensions.dart';
import 'package:whatsapp/utils/global.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final String? roomId;
  final double fontSize;
  final bool isOfPreviousMessageType;
  final bool onPrviousMessageDay;
  final Color? color;
  final Color? touchedColor;
  final bool? isSent;
  final StreamController<String>? chatIdStreamController;
  final bool inSelectMode;
  final void Function(bool selected, Message message)? onSelectToggle;

  const MessageBubble({
    super.key,
    this.color,
    this.touchedColor,
    required this.message,
    this.roomId,
    this.isSent,
    this.fontSize = 16,
    this.isOfPreviousMessageType = false,
    this.onPrviousMessageDay = true,
    this.chatIdStreamController,
    this.inSelectMode = false,
    this.onSelectToggle,
  }); //: assert(roomId != null || chatIdStreamController != null);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late Color? _bubbleColor;
  bool _selected = false;
  late bool _isSent;

  @override
  void initState() {
    super.initState();
    debugPrint("Conversation: Message state: ${widget.message.status}");

    _bubbleColor = widget.color;
    _isSent = widget.isSent ?? widget.message.senderId == UserManager.uid;
  }

  void _onTouched([details]) {
    if (_selected) return;
    _bubbleColor = widget.touchedColor;
    setState(() {});
  }

  void _whenUntouched([details]) {
    if (_selected) return;
    _bubbleColor = widget.color;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width -
        (MediaQuery.of(context).size.width * 0.15);
    const horizontalPadding = 16.0;

    if (widget.message.status != MessageStatus.seen &&
        widget.message.senderId != UserManager.uid) {
      debugPrint(
          "...........Message sender Id: ${widget.message.senderId}...............");
      BlocProvider.of<ChattingBloc>(context).add(LocalMessageUpdateEvent(
          widget.roomId!, widget.message, MessageStatus.seen));
    }

    return GestureDetector(
      onTapDown: _onTouched,
      onTapUp: _whenUntouched,
      onTapCancel: _whenUntouched,
      onTap: widget.inSelectMode ? _invertSelection : null,
      onLongPress: _invertSelection,
      child: widget.onPrviousMessageDay
          ? _buildBubble(maxWidth, horizontalPadding, context)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDayIndicator(),
                _buildBubble(maxWidth, horizontalPadding, context),
              ],
            ),
    );
  }

  Widget _buildDayIndicator() {
    return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            DateTime.fromMillisecondsSinceEpoch(widget.message.time).describe(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ));
  }

  Widget _buildBubble(
      double maxWidth, double horizontalPadding, BuildContext context) {
    return Column(
      children: [
        if(!widget.isOfPreviousMessageType)
        const SizedBox(height: 4,),
        Stack(
          children: [
            Container(
              color: Colors.transparent,
              alignment: _isSent ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: horizontalPadding,
                ),
                child: CustomPaint(
                  painter: MessageBubblePainter(
                      color: _bubbleColor ?? Theme.of(context).canvasColor,
                      isSent: _isSent,
                      isOfPreviousMessageType: widget.isOfPreviousMessageType),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _isSent
                        ? Stack(
                            children: [
                              _buildTimeStampedMessage(context, 18),
                              BlocBuilder<ChattingBloc, ChattingState>(
                                  buildWhen: (previsous, current) =>
                                      current is MessageStatusUpdateState &&
                                      current.message.id == widget.message.id,
                                  builder: (context, state) {
                                    // debugPrint(".......Message icon updated:  ${(state as MessageStatusUpdateState).message.id}, ${widget.message.id}");
                                    return Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: buildMessageStatusIcon(
                                          widget.message.status),
                                    );
                                  }),
                            ],
                          )
                        : _buildTimeStampedMessage(context, 0),
                  ),
                ),
              ),
            ),
            if (_selected)
              Positioned.fill(
                child: ColoredBox(
                  color: Theme.of(context)
                          .extension<WhatsAppThemeComponents>()
                          ?.selectedChatBubbleHighlightColor ??
                      Colors.transparent,
                ),
              )
          ],
        ),
      ],
    );
  }

  TimestampedChatMessage _buildTimeStampedMessage(
      BuildContext context, double statusIconSize) {
    return TimestampedChatMessage(
      text: widget.message.data,
      sentAt: convertTimeToString(widget.message.time),
      stateIconSize: statusIconSize,
      messageStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          // fontWeight: FontWeight.w400,

          ),
      timeStyle:
          Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
    );
  }

  void _invertSelection() {
    setState(() {
      _selected = !_selected;
    });
    widget.onSelectToggle?.call(_selected, widget.message);
  }
}

class MessageBubblePainter extends CustomPainter {
  final double _radius = 14;
  final double _l = 7;
  final Color color;
  final bool isSent;
  final bool isOfPreviousMessageType;

  MessageBubblePainter({
    required this.color,
    required this.isSent,
    required this.isOfPreviousMessageType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    if (!isSent && !isOfPreviousMessageType) {
      path.moveTo(0, _radius - 3); // Move to top-left down
      path.lineTo(-_l, 3.5);
      path.quadraticBezierTo(-_l - 2, 0, -_l + 2, 0);
    } else {
      path.moveTo(0, _radius); // Move to top-left down
      path.quadraticBezierTo(0, 0, _radius, 0); // top-left up
    }

    // path.quadraticBezierTo(0, 0, _d, 0);  // top-left up

    if (isSent && !isOfPreviousMessageType) {
      path.lineTo(size.width + _l, 0); // top-right up
      path.quadraticBezierTo(size.width + _l + 2, 1, size.width + _l, 3.5);
      path.lineTo(size.width, _radius - 3); // top-right down
    } else {
      path.lineTo(size.width - _radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, _radius);
    }

    path.lineTo(size.width, size.height - _radius); // bottom-right up

    path.quadraticBezierTo(size.width, size.height, size.width - _radius,
        size.height); // bottom-right down

    path.lineTo(_radius, size.height); // bottom-left down

    path.quadraticBezierTo(
        0, size.height, 0, size.height - _radius); // bottom-left up

    path.close();

    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;

    canvas.drawShadow(path, const Color(0xA09E9E9E), 0.3, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MessageBubblePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
