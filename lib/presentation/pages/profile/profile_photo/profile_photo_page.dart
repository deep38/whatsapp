import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';

class ProfilePhotoPage extends StatefulWidget {
  const ProfilePhotoPage({
    super.key,
    required this.user,
    this.showMini = true,
    this.miniPhotoSize = 250,
  });

  final WhatsAppUser user;
  final bool showMini;
  final double miniPhotoSize;

  @override
  State<ProfilePhotoPage> createState() => _ProfilePhotoPageState();
}

class _ProfilePhotoPageState extends State<ProfilePhotoPage> {
  final GlobalKey _miniPhotoKey = GlobalKey();
  final PhotoViewControllerBase<PhotoViewControllerValue>
      _photoViewControllerBase = PhotoViewController();

  Size? _miniPhotoSize;
  Offset? _miniPhotoPosition;

  late bool _isMini;

  @override
  void initState() {
    super.initState();
    _isMini = widget.showMini;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final miniPhotoRenderBox =
          _miniPhotoKey.currentContext?.findRenderObject() as RenderBox?;
      _miniPhotoSize = miniPhotoRenderBox?.size;
      _miniPhotoPosition = miniPhotoRenderBox?.localToGlobal(Offset.zero);

      debugPrint("MINILOADED: $_miniPhotoSize $_miniPhotoPosition");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _isMini ? null : _buildAppBar(),
        body: _isMini ? _buildMiniPhoto() : _buildFullPhoto(),
        // AnimatedSwitcher(
        //   duration: const Duration(milliseconds: 500),
        //   transitionBuilder: (child, animation) {
        //     return ScaleTransition(scale: animation, child: child,);
        //   },
        //   child: _isMini ? _buildMiniPhoto() : _buildFullPhoto(),
        // ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(widget.user.name ?? widget.user.phoneNo),
    );
  }

  Widget _buildMiniPhoto() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        alignment: Alignment.topCenter,
        color: Colors.black.withOpacity(0.3),
        child: SizedBox(
          width: widget.miniPhotoSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 128,
              ),
              Stack(
                children: [
                  InkWell(
                    onTap: _openFullPhoto,
                    child: Hero(
                      tag: widget.user.phoneNo,
                      flightShuttleBuilder: (flightContext, animation,
                          flightDirection, fromHeroContext, toHeroContext) {
                        return _heroFlightWidget();
                      },
                      child: CachedNetworkImage(
                        key: _miniPhotoKey,
                        imageUrl: widget.user.photoUrl ?? "#",
                        height: widget.miniPhotoSize,
                        width: widget.miniPhotoSize,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.user.name ?? widget.user.phoneNo,
                    ),
                  ),
                ],
              ),
              Container(
                color: Theme.of(context).canvasColor,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(
                      WhatsAppIcons.message,
                      () {},
                    ),
                    _buildIconButton(
                      WhatsAppIcons.call,
                      () {},
                    ),
                    _buildIconButton(
                      WhatsAppIcons.videocam_rounded,
                      () {},
                    ),
                    _buildIconButton(
                      WhatsAppIcons.info_circle_fill_teal,
                      () {},
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullPhoto() {
    return CachedNetworkImage(
      imageUrl: widget.user.photoUrl ?? "#",
      imageBuilder: (context, imageProvider) => Hero(
        tag: widget.user.phoneNo,
        flightShuttleBuilder: (flightContext, animation, flightDirection,
            fromHeroContext, toHeroContext) {
          return flightDirection == HeroFlightDirection.push
              ? CachedNetworkImage(imageUrl: widget.user.photoUrl ?? "#")
              : _heroFlightWidget();
        },
        child: PhotoView(
          controller: _photoViewControllerBase,
          imageProvider: imageProvider,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.black,
        child: const Center(
          child: Text("No profile photo"),
        ),
      ),
    );
  }

  Widget _heroFlightWidget() {
    return CachedNetworkImage(
      imageUrl: widget.user.photoUrl ?? "",
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: Colors.teal,
      ),
    );
  }

  void _openFullPhoto() {
    setState(() {
      _isMini = false;
    });
  }
}
