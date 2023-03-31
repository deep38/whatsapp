import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';

class Camera extends StatelessWidget {
  const Camera({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Icon(WhatsAppIcons.camera_fill, size: min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),),
        ),
      ),
    );
  }
}