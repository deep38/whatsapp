import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whatsapp/presentation/widgets/whatsapp_elevated_button.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 40,
          ),
          SvgPicture.asset(
            AssetSvgs.start_community,
            width: 360,
            height: 200,
          ),
          Text(
            "Stay connected with community",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(
            height: 18,
          ),
          Text(
            '''Communities bring members together in topic-based groups, and make it easy to get admin announcements. Any community you're added to will appear here.''',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          WhatsAppElevatedButton(
            width: MediaQuery.of(context).size.width,
            borderRadius: 32,
            onPressed: () {},
            child: const Text("Start your community", textAlign: TextAlign.center,),
            
          )
        ],
      ),
    );
  }
}
