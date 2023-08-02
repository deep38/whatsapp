import 'package:flutter/material.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import '../../../../../utils/mapers/asset_images.dart';
import 'package:whatsapp/presentation/widgets/list_tile.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';
import 'package:whatsapp/presentation/widgets/profile_photo_indicator.dart';
import 'package:whatsapp/presentation/widgets/security_message.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildMyStatus(),
        _buildTitle(context, "Recent updates"),
        _buildRecentUpdates(),
        _buildTitle(context, "Viewed updates"),
        _buildViewedUpdates(),
        const SliverToBoxAdapter(child: SecurityMessage(securityFieldName: "Status updates",))
      ],
    );
  }

  SliverToBoxAdapter _buildMyStatus() {
    return const SliverToBoxAdapter(
        child: WhatsAppListTile(
          title: Text("My status"),
          subtitle: Text("Tap to add status update"),
          leading: ProfilePhoto(
            placeholderPath: AssetImages.default_profile,
            imageUrl: "#",
            indicator: ProfilePhotoIndicator(
              icon: Icon(
                WhatsAppIcons.add, 
                color: Colors.white, 
                size: 14,
              ),
            )
          ),
        ),
      );
  }

  SliverList _buildRecentUpdates() {
    return SliverList.builder(
      itemBuilder: (context, index) {
        return WhatsAppListTile(
          leading: const ProfilePhoto(
            imageUrl: "#",
            placeholderPath: AssetImages.default_profile,
          ), 
          title: Text("Status $index"),
          subtitle: const Text("Today, 01:11 am"),
        );
      },
      itemCount: 3,
    );
  }

  SliverList _buildViewedUpdates() {
    return SliverList.builder(
      itemBuilder: (context, index) {
        return WhatsAppListTile(
          leading: const ProfilePhoto(
            imageUrl: "#",
            placeholderPath: AssetImages.default_profile,
          ), 
          title: Text("Status $index"),
          subtitle: const Text("Today, 01:11 am"),
        );
      },
      itemCount: 3,
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}