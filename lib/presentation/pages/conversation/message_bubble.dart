import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/helpers/message_helper.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/conversation/message_change_notifier.dart';
import '../../../../utils/enums.dart';
import 'message_bubble_painter.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final String? roomId;
  final double fontSize;
  final bool isOfPreviousMessageType;
  final Color? color;
  final Color? touchedColor;
  final bool isSent;
  final StreamController<String>? chatIdStreamController;

  const MessageBubble({
    super.key,
    this.color,
    this.touchedColor,
    required this.message,
    this.roomId,
    this.isSent = false,
    this.fontSize = 16,
    this.isOfPreviousMessageType = false,
    this.chatIdStreamController,
  }) : assert(roomId != null || chatIdStreamController != null);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> implements MessageCallbacks{
  
  final StreamController<DocumentSnapshot<Map<String, dynamic>>> _messageStreamController = StreamController();
  late MessageChangeNotifier _messageChangeNotifier;
  late MessageHelper _messageHelper;

  // String? _roomId;
  Color? _bubbleColor;

  @override
  void initState() {
    super.initState();
    debugPrint("Conversation: Message state: ${widget.message.state}");

    _messageHelper = MessageHelper(
      message: widget.message,
      roomId: widget.roomId,
      roomIdStream: widget.chatIdStreamController,
      messageCallbacks: this,
    );

    _bubbleColor = widget.color;
    _messageChangeNotifier = MessageChangeNotifier(widget.message);
  }

  void _setStateTouched() {
    _bubbleColor = widget.touchedColor;
    setState(() {});
  }

  void _setStateUnTouched() {
    _bubbleColor = widget.color;
    setState(() {});
  }

  @override
  void dispose() {
    _messageChangeNotifier.dispose();
    _messageStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width -
        (MediaQuery.of(context).size.width * 0.25);
    const horizontalPadding = 16.0;

    return GestureDetector(
      onTapDown: (details) {
        _setStateTouched();
      },
      onTapUp: (details) {
        _setStateUnTouched();
      },
      onTapCancel: _setStateUnTouched,
      child: Container(
        color: Colors.transparent,
        alignment: widget.isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          padding: EdgeInsets.only(
              top: widget.isOfPreviousMessageType ? 4 : 12,
              left: horizontalPadding,
              right: horizontalPadding),
          child: _customPaint(context, maxWidth, horizontalPadding),
        ),
      ),
    );
  }

  Widget _customPaint(
      BuildContext context, double maxWidth, double horizontalPadding) {
    const double messageStateIconSize = 18;
    final double infoWidth =
        63 + 6 + (widget.isSent ? messageStateIconSize : 0);
    final availableWidth = maxWidth -
        (2 * (horizontalPadding + 8)) -
        infoWidth -
        6; // 6 is left padding of info
    final textData = _getMessageWidth(context, availableWidth + infoWidth + 6);
    double lastLineWidth = textData['width'];
    double longestLineWidth = textData['longestLineWidth'];

    return CustomPaint(
      painter: MessageBubblePainter(
        color: _bubbleColor ?? Colors.white,
        messageType: widget.isSent ? MessageType.sent : MessageType.received,
        isOfPreviousMessageType: widget.isOfPreviousMessageType,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: longestLineWidth < availableWidth
            ? _buildRow(context, infoWidth, messageStateIconSize)
            : (lastLineWidth % (availableWidth + infoWidth)) + infoWidth <
                    availableWidth
                ? _buildStack(context, infoWidth, messageStateIconSize)
                : _buildColumn(context, infoWidth, messageStateIconSize),
      ),
    );
  }

  Column _buildColumn(
      BuildContext context, double infoWidth, double messageStateIconSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildMessageText(context),
        _buildMessageInfo(context, infoWidth, messageStateIconSize)
      ],
    );
  }

  Stack _buildStack(
      BuildContext context, double infoWidth, double messageStateIconSize) {
    return Stack(
      children: [
        _buildMessageText(context),
        Positioned(
          right: 0,
          bottom: 0,
          child: _buildMessageInfo(context, infoWidth, messageStateIconSize),
        )
      ],
    );
  }

  Row _buildRow(
      BuildContext context, double infoWidth, double messageStateIconSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildMessageText(context),
        _buildMessageInfo(context, infoWidth, messageStateIconSize)
      ],
    );
  }

  Container _buildMessageText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width * 0.3)),
      child: Text(
        widget.message.data,
      ),
    );
  }

  Widget _buildMessageInfo(
      BuildContext context, double width, double iconSize) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 6,
            ),
            child: Text(
              "09:30 pm",
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          if (widget.isSent && widget.message.state != null)
            ValueListenableBuilder(
                valueListenable: _messageChangeNotifier,
                builder: (context, message, child) =>
                    _buildMessageState(message.state!, iconSize))
        ],
      ),
    );
  }

  Icon _buildMessageState(MessageState state, double iconSize) {
    Color iconColor = Colors.grey.shade500;
    IconData icon = WhatsAppIcons.clock_rounded;
    switch (state) {
      case MessageState.waiting:
        icon = WhatsAppIcons.clock_rounded;
        iconSize = 16;
        break;
      case MessageState.sent:
        icon = WhatsAppIcons.tick;
        iconSize = 16;
        break;
      case MessageState.received:
        icon = WhatsAppIcons.double_tick;
        break;
      case MessageState.viewed:
        icon = WhatsAppIcons.double_tick;
        iconColor = Colors.blue;
        break;
      case MessageState.failed:
        icon = WhatsAppIcons.warning_circle_outline;
        iconColor = Colors.red;
        break;
      default:
        break;
    }

    return Icon(
      icon,
      size: iconSize,
      color: iconColor,
    );
  }

  Map<String, dynamic> _getMessageWidth(context, maxWidth) {
    TextSpan span = TextSpan(
      text: widget.message.data,
      style: Theme.of(context).textTheme.bodyMedium,
    );

    TextPainter textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      maxLines: null,
    );

    textPainter.layout(maxWidth: maxWidth);

    List<LineMetrics> lineMetrics = textPainter.computeLineMetrics();
    // double lastLineWidth = lineMetrics.last.width;
    double longestLineWidth = 0;
    // bool lastLineIsLongest = true;
    for (var lineMetric in lineMetrics) {
      if (lineMetric.width > longestLineWidth) {
        longestLineWidth = lineMetric.width;
      }
    }
    // debugPrint("$message: $lineMetrics");
    return {
      "width": lineMetrics.last.width,
      "longestLineWidth": longestLineWidth
    };
  }
  
  @override
  void onMessageDataUpdate(String data) {
    
  }
  
  @override
  void onMessageDeleted() {
    
  }
  
  @override
  void onMessageSent(String id) {
    
  }
  
  @override
  void onMessageStateUpdate(MessageState? state) {
    _messageChangeNotifier.updateState(state);
  }
}
