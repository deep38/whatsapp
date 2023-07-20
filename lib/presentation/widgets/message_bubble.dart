import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/bloc/chatting/chats_bloc.dart';
import 'package:whatsapp/bloc/chatting/chats_event.dart';
import 'package:whatsapp/bloc/chatting/chats_state.dart';
import 'package:whatsapp/data/helpers/message_helper.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/widgets/time_stamped_chat_message.dart';
import 'package:whatsapp/utils/enums.dart';
import 'package:whatsapp/utils/global.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final String? roomId;
  final double fontSize;
  final bool isOfPreviousMessageType;
  final Color? color;
  final Color? touchedColor;
  final bool? isSent;
  final StreamController<String>? chatIdStreamController;

  const MessageBubble({
    super.key,
    this.color,
    this.touchedColor,
    required this.message,
    this.roomId,
    this.isSent,
    this.fontSize = 16,
    this.isOfPreviousMessageType = false,
    this.chatIdStreamController,
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

    if(widget.message.status != MessageStatus.seen && widget.message.senderId != UserManager.uid) {
      BlocProvider.of<ChattingBloc>(context).add(LocalMessageUpdateEvent(widget.roomId!, widget.message.id, MessageStatus.seen));
    }

    return GestureDetector(
      onTapDown: _onTouched,
      onTapUp: _whenUntouched,
      onTapCancel: _whenUntouched,
      onLongPress: () => setState(() {
        _selected = !_selected;
      }),
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
            alignment: _isSent ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              padding: EdgeInsets.symmetric(
                vertical: widget.isOfPreviousMessageType ? 2 : 8,
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
                              buildWhen: (previsous, current) => current is MessageStatusUpdateState && current.messageId == widget.message.id,
                              builder: (context, state) { 
                                debugPrint("Message icon updated: $state");
                                return Positioned(
                                right: 0,
                                bottom: 0,
                                child: state is MessageStatusUpdateState
                                  ? _buildMessageStatusIcon(state.status)
                                  : _buildMessageStatusIcon(MessageStatus.sending),
                              );
                              }
                            ),
                          ],
                        )
                      : _buildTimeStampedMessage(context, 0),
                ),
              ),
            ),
          ),
          if (_selected)
            const Positioned.fill(
                child: ColoredBox(
              color: Color.fromARGB(104, 76, 175, 79),
            ))
        ],
      ),
    );
  }

  TimestampedChatMessage _buildTimeStampedMessage(BuildContext context, double statusIconSize) {
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

  // Widget _customPaint(
  //     BuildContext context, double maxWidth, double horizontalPadding) {
  //   const double messageStateIconSize = 18;
  //   final double infoWidth =
  //       63 + 6 + (widget.isSent ? messageStateIconSize : 0);
  //   final availableWidth = maxWidth -
  //       (2 * (horizontalPadding + 8)) -
  //       infoWidth -
  //       6; // 6 is left padding of info
  //   final textData = _getMessageWidth(context, availableWidth + infoWidth + 6);
  //   double lastLineWidth = textData['width'];
  //   double longestLineWidth = textData['longestLineWidth'];

  //   return CustomPaint(
  //     painter: MessageBubblePainter(
  //       color: _bubbleColor ?? Colors.white,
  //       isSent: widget.isSent,
  //       isOfPreviousMessageType: widget.isOfPreviousMessageType,
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //       child: longestLineWidth < availableWidth
  //           ? _buildRow(context, infoWidth, messageStateIconSize)
  //           : (lastLineWidth % (availableWidth + infoWidth)) + infoWidth <
  //                   availableWidth
  //               ? _buildStack(context, infoWidth, messageStateIconSize)
  //               : _buildColumn(context, infoWidth, messageStateIconSize),
  //     ),
  //   );
  // }

  // Column _buildColumn(
  //     BuildContext context, double infoWidth, double messageStateIconSize) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       _buildMessageText(context),
  //       _buildMessageInfo(context, infoWidth, messageStateIconSize)
  //     ],
  //   );
  // }

  // Stack _buildStack(
  //     BuildContext context, double infoWidth, double messageStateIconSize) {
  //   return Stack(
  //     children: [
  //       _buildMessageText(context),
  //       Positioned(
  //         right: 0,
  //         bottom: 0,
  //         child: _buildMessageInfo(context, infoWidth, messageStateIconSize),
  //       )
  //     ],
  //   );
  // }

  // Row _buildRow(
  //     BuildContext context, double infoWidth, double messageStateIconSize) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       _buildMessageText(context),
  //       _buildMessageInfo(context, infoWidth, messageStateIconSize)
  //     ],
  //   );
  // }

  // Container _buildMessageText(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.only(bottom: 4),
  //     constraints: BoxConstraints(
  //         maxWidth: MediaQuery.of(context).size.width -
  //             (MediaQuery.of(context).size.width * 0.3)),
  //     child: Text(
  //       widget.message.data,
  //     ),
  //   );
  // }

  // Widget _buildMessageInfo(
  //     BuildContext context, double width, double iconSize) {
  //   return SizedBox(
  //     width: width,
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.only(
  //             left: 6,
  //           ),
  //           child: Text(
  //             "09:30 pm",
  //             style: Theme.of(context).textTheme.labelMedium,
  //           ),
  //         ),
  //         if (widget.isSent && widget.message.status != null)
  //           ValueListenableBuilder(
  //               valueListenable: _messageChangeNotifier,
  //               builder: (context, message, child) =>
  //                   _buildMessageState(message.state!, iconSize))
  //       ],
  //     ),
  //   );
  // }

  Icon _buildMessageStatusIcon(MessageStatus status) {
    Color iconColor = Colors.grey.shade500;
    IconData icon = WhatsAppIcons.clock_rounded;
    double iconSize = 18;

    (IconData, Color, double) getPropertiesOfIcon(MessageStatus status)  => switch (status) {
      (MessageStatus.waiting || MessageStatus.sending) 
        => (WhatsAppIcons.clock_rounded, iconColor, 14),
      MessageStatus.sent => (WhatsAppIcons.tick, iconColor, 14),
      MessageStatus.received => (WhatsAppIcons.double_tick, iconColor, iconSize),
      MessageStatus.seen => (WhatsAppIcons.double_tick, Colors.blue, iconSize),
      MessageStatus.failed => (WhatsAppIcons.warning_circle_outline, Colors.red, 14),
      
    };
    (icon, iconColor, iconSize) = getPropertiesOfIcon(status);

    return Icon(
      icon,
      size: iconSize,
      color: iconColor,
    );
  }

  

  // Map<String, dynamic> _getMessageWidth(context, maxWidth) {
  //   TextSpan span = TextSpan(
  //     text: widget.message.data,
  //     style: Theme.of(context).textTheme.bodyMedium,
  //   );

  //   TextPainter textPainter = TextPainter(
  //     text: span,
  //     textDirection: TextDirection.ltr,
  //     textScaleFactor: MediaQuery.of(context).textScaleFactor,
  //     maxLines: null,
  //   );

  //   textPainter.layout(maxWidth: maxWidth);

  //   List<LineMetrics> lineMetrics = textPainter.computeLineMetrics();
  //   // double lastLineWidth = lineMetrics.last.width;
  //   double longestLineWidth = 0;
  //   // bool lastLineIsLongest = true;
  //   for (var lineMetric in lineMetrics) {
  //     if (lineMetric.width > longestLineWidth) {
  //       longestLineWidth = lineMetric.width;
  //     }
  //   }
  //   // debugPrint("$message: $lineMetrics");
  //   return {
  //     "width": lineMetrics.last.width,
  //     "longestLineWidth": longestLineWidth
  //   };
  // }

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
