import 'package:flutter/material.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';


class TabBarHeader extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final double maxHeight;
  final double minHeight;
  final Color backgroundColor;

  TabBarHeader({
    required this.tabController,
    this.maxHeight = 55,
    this.minHeight = 55,
    required this.backgroundColor,
  });

  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    
    return Container(
      height: minHeight,
      color: backgroundColor,
      child: _tabBar(context),
    );
  }

  TabBar _tabBar(BuildContext context) {
    const double communityTabbarWidth = 40;
    final double tabbarWidth = (MediaQuery.of(context).size.width - communityTabbarWidth) / 3;
    
    return TabBar(
        controller: tabController,
        isScrollable: true,
        labelPadding: EdgeInsets.zero,

        tabs: [
          const SizedBox(
            width: communityTabbarWidth,
            child: Tab(icon: Icon(WhatsAppIcons.community, size: 32,), iconMargin: EdgeInsets.only(bottom: 0), ),
          ),
          SizedBox(
            width: tabbarWidth,
            child: const Tab(
              text: "Chats",
            ),
          ),
          SizedBox(
            width: tabbarWidth,
            child:  const Tab(
              child: Text("Status ●"),
            ),
          ),
          SizedBox(
            width: tabbarWidth,
            child: const Tab(
              text: "Calls",
            ),
          ),
          
        ],
      );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(TabBarHeader oldDelegate) {
    if(oldDelegate.backgroundColor != backgroundColor) {
      return true;
    }
    return false;
  }

}