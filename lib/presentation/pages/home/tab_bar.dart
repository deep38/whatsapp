import 'package:flutter/material.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/widgets/unread_count_indicator.dart';


class TabBarHeader extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final double maxHeight;
  final double minHeight;
  final Color backgroundColor;

  final ValueNotifier<int> unreadChatsCountNotifier;
  final ValueNotifier<bool> newStatusUpdateNotifier;

  TabBarHeader({
    required this.tabController,
    this.maxHeight = 55,
    this.minHeight = 55,
    required this.backgroundColor,
    required this.unreadChatsCountNotifier,
    required this.newStatusUpdateNotifier,
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
            child:  Tab(
              // text: "Chats",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chats"),
                  const SizedBox(width: 4,),
                  ValueListenableBuilder(
                    valueListenable: unreadChatsCountNotifier,
                    builder: (context, count, child) => count > 0
                    ? UnreadCountIndicator(text: "$count")
                    : const SizedBox(),
                  )
                ],
              ),
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