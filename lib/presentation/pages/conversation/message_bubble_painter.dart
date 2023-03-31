
import 'package:flutter/material.dart';
import 'package:whatsapp/utils/enums.dart';

class MessageBubblePainter extends CustomPainter {
  final double _radius = 14;
  final double _l = 7;
  final Color color;
  final MessageType messageType;
  final bool isOfPreviousMessageType;

  MessageBubblePainter({
    required this.color,
    required this.messageType,
    required this.isOfPreviousMessageType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    if(messageType == MessageType.received && !isOfPreviousMessageType) {
      path.moveTo(0, _radius - 3);   // Move to top-left down
      path.lineTo(-_l, 3.5);
      path.quadraticBezierTo(-_l - 2, 0, -_l + 2, 0);
    } else {
      path.moveTo(0, _radius);   // Move to top-left down
      path.quadraticBezierTo(0, 0, _radius, 0);  // top-left up
    }
    
    // path.quadraticBezierTo(0, 0, _d, 0);  // top-left up

    if(messageType == MessageType.sent && !isOfPreviousMessageType) {
      path.lineTo(size.width + _l, 0);  // top-right up
      path.quadraticBezierTo(size.width + _l + 2, 1, size.width + _l, 3.5);
      path.lineTo(size.width, _radius - 3);    // top-right down
    } else {
      path.lineTo(size.width - _radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, _radius);
    }

    path.lineTo(size.width, size.height - _radius);    // bottom-right up

    path.quadraticBezierTo(size.width, size.height, size.width - _radius, size.height); // bottom-right down

    path.lineTo(_radius, size.height);  // bottom-left down

    path.quadraticBezierTo(0, size.height, 0, size.height - _radius);  // bottom-left up

    path.close();

    Paint paint = Paint()..color = color..strokeCap = StrokeCap.round;

    canvas.drawShadow(path, const Color(0xA09E9E9E), 0.3, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MessageBubblePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}