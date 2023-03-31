import 'package:flutter/material.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import '../../../utils/global.dart';

class SecurityMessage extends StatelessWidget {
  final String securityFieldName;

  const SecurityMessage({
    super.key,
    required this.securityFieldName
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 130,
      padding: const EdgeInsets.only(top: 16),

      decoration: BoxDecoration(
        color: Theme.of(context).listTileTheme.tileColor,
        border: const Border(
          top: BorderSide(
            color: Color.fromARGB(50, 158, 158, 158),
            width: 0.5
          )
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(WhatsAppIcons.lock_fill, size: 12,),
          Text(
            "Your $securityFieldName are ",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          InkWell(
            onTap: (){
              showSnackBar(context, "Not realy");
            },
            splashColor: Theme.of(context).colorScheme.primary.withAlpha(70),
            child: Text(
              "end-to-end encrypted",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary
              ),
            )
          )
        ],
      ),
    );
  }
}