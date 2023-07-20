import 'dart:async';

import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/data/database/table_helper.dart';
import 'package:whatsapp/data/database/tables/chat_table.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/presentation/pages/camera/camera.dart';
import 'package:whatsapp/presentation/pages/device_contacts/device_contact_page.dart';
import 'package:whatsapp/presentation/pages/home/chat_list/chat_list_page.dart';
import 'package:whatsapp/presentation/pages/home/status/status_page.dart';
import 'package:whatsapp/presentation/pages/home/tab_bar.dart';
import 'package:whatsapp/presentation/pages/settings/settings.dart';
import 'package:whatsapp/presentation/providers/select_count_provider.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import '../../../../utils/enums.dart';
import '../../../../utils/global.dart';
import 'package:whatsapp/presentation/widgets/search/whatsapp_search.dart';

final List<double> _searchViewHeight = [0, 150, 56, 56];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final TableHelper _tableHelper = TableHelper();

  late Animation<double> _circularRevealAnimation;

  final ValueNotifier<bool> _selectModeNotifer = ValueNotifier(false);
  final ValueNotifier<bool> _searchVisibilityNotifier = ValueNotifier(false);
  late ValueNotifier<double> _searchViewHeightChangeNotifier;
  final ValueNotifier<bool> _fabChangeNotifier = ValueNotifier(false);
  Function()? _onFabPressed = null;

  late SelectCountProvider _selectCountProvider;

  late TabController _tabController;
  late AnimationController _searchAnimationController;
  late StreamController<Offset> _actionSearchStreamController;

  final GlobalKey _actionSearchKey = GlobalKey();
  final GlobalKey<ChatListState> _chatListKey = GlobalKey();

  final List<Chat> _selectedChats = [];

  bool _isOffsetLoaded = false;
  
  final int _initialTabIndex = 1;
  
  @override
  void initState() {
    super.initState();

    _tabController = TabController(initialIndex: _initialTabIndex, length: 4, vsync: this);
    _searchViewHeightChangeNotifier = ValueNotifier(_searchViewHeight[_initialTabIndex]);
    _selectCountProvider = Provider.of<SelectCountProvider>(context, listen: false);
    _actionSearchStreamController = StreamController<Offset>();
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _circularRevealAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeIn
    );
    
    _tabController.addListener(_tabChangeListener);

    WidgetsBinding.instance.addPostFrameCallback(_afterWidgetsLoad);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectCountProvider.dispose();
    _actionSearchStreamController.close();
    _searchAnimationController.dispose();
    
    super.dispose();
  }

  void _setOnFabPressed(Function()? onFabPressed) {
    _onFabPressed = onFabPressed;
    debugPrint("Function seted: $_onFabPressed");
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [

            NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: NestedScrollView(
                floatHeaderSlivers: true,
            
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    _buildAppBar(context),
                    _buildTabBar(context),
                  ];
                },
                body: _buildBody(),
              ),
            ),
            
            _buildSearch()
          ],
        ),

        floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            onPressed: _handleFabPressed,
            child: const Icon(
              WhatsAppIcons.message
            ),
          ),
      ),
    );
  }

  void _handleFabPressed() {
    if(_onFabPressed != null) {
      _onFabPressed?.call(); 
    } else {
      showSnackBar(context, "Unimplemented");
    }
  }

  Widget _buildAppBar(BuildContext context) {
    
    return ValueListenableBuilder(
      valueListenable: _searchViewHeightChangeNotifier,
      builder: (context, value, child) => AnimatedBuilder(
        animation: _searchAnimationController,
        builder: (context, child) => ValueListenableBuilder(
          valueListenable: _selectModeNotifer,
          builder: (context, inSelectMode, child) {
            
            Color surfaceColor = _surfaceColor(inSelectMode);
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: surfaceColor
              )
            );

            return SliverAppBar(
              backgroundColor: surfaceColor,
              surfaceTintColor: surfaceColor,
              pinned: inSelectMode,
              floating: true,
              snap: true,
              toolbarHeight: value <= 56 ? 56 * (1 - _searchAnimationController.value) : 56,
              expandedHeight: value > 56 ? (value - 56) * _searchAnimationController.value : null,
              elevation: 0,
              
              title: !inSelectMode ? 
                const Text("WhatsApp") : 
                Consumer<SelectCountProvider>(
                  builder: (context, value, child) => 
                    Text("${_selectCountProvider.count}", style: const TextStyle(color: Colors.white),)
                ),
            
              leading: inSelectMode ? IconButton(onPressed: () {
                _toggleSelectMode(false);
              }, icon: const Icon(Icons.arrow_back)) : null,
              
            
              actions: !inSelectMode ? _appBarActions() : _selectModeActions(),
            );
          },
        ),
      ),
    );
  }

  
  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children:  [
        const Center(
          child: Text("Community"),
        ),
        ChatList(
          key: _chatListKey,
          toggleSelectMode: _toggleSelectMode,
          selectCountProvider: _selectCountProvider,
          selectModeNotifier: _selectModeNotifer,
          selectedChatList: _selectedChats,
          setOnFabPressed: _setOnFabPressed,
        ),
        StatusPage(setOnFabPressed: _setOnFabPressed,),
        const Center(
          child: Text("Calls"),
        ),
        
      ]
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _selectModeNotifer,
      builder: (context, inSelectMode, child) => SliverPersistentHeader(
        pinned: !inSelectMode,
        floating: inSelectMode,
        
        delegate: TabBarHeader(
          tabController: _tabController,
          backgroundColor: _surfaceColor(inSelectMode)
        )
      ),
    );
  }

  StreamBuilder<Offset> _buildSearch() {
    return StreamBuilder<Offset>(
      stream: _actionSearchStreamController.stream,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return CircularRevealAnimation(
            animation: _circularRevealAnimation,
            centerOffset: snapshot.data,
            child: ValueListenableBuilder(
              valueListenable: _searchViewHeightChangeNotifier,
              builder: (context, value, child) => WhatsAppSearch(
                height: value,
                visibilityNorifier: _searchVisibilityNotifier,
                onClose: _hideSearchBar,
              ),
            ),
          );
        }
        return SizedBox.fromSize(size: Size.zero);
      }
    );
  }

  List<Widget> _appBarActions() {
    return <Widget>[
      IconButton(
        onPressed: _openCamera,
        icon: const Icon(WhatsAppIcons.camera_outline_small),
        tooltip: "Camera",
      ),

      IconButton(
        key: _actionSearchKey,
        onPressed: _showSearchBar,
        icon: const Icon(WhatsAppIcons.search),
        tooltip: "Search",
      ),

      _appBarMoreOptions(),
    ];
  }

  List<Widget> _selectModeActions() {
    return <Widget> [
      IconButton(
        tooltip: "Pin chat",
        onPressed: () {debugPrint("$_selectedChats");},
        icon: const Icon(
          WhatsAppIcons.pin,
          color: Colors.white,
          size: 22,
        ),
      ),
      IconButton(
        tooltip: "Delete chat",
        onPressed: _deleteSelectedChats,
        icon: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      IconButton(
        tooltip: "Mute notifications",
        onPressed: () {},
        icon: const Icon(
          WhatsAppIcons.mute,
          color: Colors.white,
        ),
      ),
      IconButton(
        tooltip: "Archive chat",
        onPressed: () {},
        icon: const Icon(
          Icons.archive,
          color: Colors.white,
        ),
      ),
      _selectModeAppBarMoreOptions(),
    ];
  }


  Widget _appBarMoreOptions() {
    return PopupMenuButton<HomeActionBarMoreOptions>(
      tooltip: "More options",
      icon: const Icon(
        Icons.more_vert,
      ),
      onSelected: _onOptionSelected,
      itemBuilder: (context) =>
        [
          const PopupMenuItem<HomeActionBarMoreOptions>(
            value: HomeActionBarMoreOptions.newGroup,
            child: Text("New group"),
          ),
          const PopupMenuItem<HomeActionBarMoreOptions>(
            value: HomeActionBarMoreOptions.newBroadcast,
            child: Text("New broadcast"),
          ),
          const PopupMenuItem<HomeActionBarMoreOptions>(
            value: HomeActionBarMoreOptions.linkedDevices,
            child: Text("Linked devices"),
          ),
          const PopupMenuItem<HomeActionBarMoreOptions>(
            value: HomeActionBarMoreOptions.starredMessages,
            child: Text("Starred messages"),
          ),
          const PopupMenuItem<HomeActionBarMoreOptions>(
            value: HomeActionBarMoreOptions.settings,
            child: Text("Settings"),
          ),
          
        ],
    );
  }

  Widget _selectModeAppBarMoreOptions() {
    return PopupMenuButton(
      tooltip: "More options",
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSecondary,
      ),

      itemBuilder: (context) =>
        [
          const PopupMenuItem<String>(
            value: "Add chat shortcut",
            child: Text("Add chat shortcut"),
          ),
          const PopupMenuItem<String>(
            value: "View contact",
            child: Text("View contact"),
          ),
          const PopupMenuItem<String>(
            value: "Mark as unread",
            child: Text("Mark as unread"),
          ),
          const PopupMenuItem<String>(
            value: "Select all",
            child: Text("Select all"),
          ),
        ]
    );
  }

  void _afterWidgetsLoad(Duration duration) {
    debugPrint("Widgets loads");
    if(!_isOffsetLoaded) {
      RenderBox? actionSearchRenderBox = _actionSearchKey.currentContext?.findRenderObject() as RenderBox?;
      debugPrint("Offset null ${_actionSearchKey.currentContext}");
      
      if(actionSearchRenderBox != null) {
        debugPrint("Action found");
        _isOffsetLoaded = true;
        Size buttonSize = actionSearchRenderBox.size;
        _actionSearchStreamController.add(actionSearchRenderBox.localToGlobal(Offset.zero) + Offset(buttonSize.width / 2, -buttonSize.height / 4));
      }
    }
  }


  void _tabChangeListener() {
    if(_selectModeNotifer.value) _toggleSelectMode(false);

    _searchViewHeightChangeNotifier.value = _searchViewHeight[_tabController.index];

  }

  void _showSearchBar() {
    _searchAnimationController.forward();
    _searchVisibilityNotifier.value = true;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarColor: Theme.of(context).dialogTheme.backgroundColor,
      )
    );
  }

  void _hideSearchBar() {
    _searchAnimationController.reverse();
    _searchVisibilityNotifier.value = false;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Theme.of(context).colorScheme.surface,
      )
    );
  }


  void _onOptionSelected(HomeActionBarMoreOptions value) {
    switch (value) {
      case HomeActionBarMoreOptions.newGroup:
        _goToCreateNewGroup();
        break;
      case HomeActionBarMoreOptions.newBroadcast:
        _goToCreateNewBroadcast();
        break;
      case HomeActionBarMoreOptions.linkedDevices:
        _showLinkedDevices();
        break;
      case HomeActionBarMoreOptions.starredMessages:
        _showStarredMessages();
        break;
      case HomeActionBarMoreOptions.settings:
        _goToSettings();
        break;
    }
  }

  void _openCamera() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Camera()));
  }

  void _goToCreateNewGroup() {
    showSnackBar(context, "New group: Unimplemented");
  }

  void _goToCreateNewBroadcast() {
    showSnackBar(context, "New broadcast: Unimplemented");
  }

  void _showLinkedDevices() {
    showSnackBar(context, "Linked devices: Unimplemented");
  }

  void _showStarredMessages() {
    showSnackBar(context, "Starred messages: Unimplemented");
  }

  void _goToSettings() {
    debugPrint("In settings");
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }


  void _deleteSelectedChats() async {
    for (var chat in _selectedChats) {
      await _tableHelper.deleteChat(chat.id);
    }
    _selectedChats.clear();
    _toggleSelectMode(false);
  }


  bool _onScrollNotification(ScrollNotification notification) {
    if(notification is ScrollStartNotification) {
      if(_searchAnimationController.isCompleted) {
        _hideSearchBar();
      }
      return true;
    }
    return false;
  }


  
  void _toggleSelectMode(bool inSelectMode) {
    if(_selectCountProvider.count > 0) _selectCountProvider.setCount(0); 
    _selectModeNotifer.value = inSelectMode;
  }


  Color _surfaceColor(bool inSelectMode) {
    return !inSelectMode ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.secondary;
  }
  
}