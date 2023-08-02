// import 'package:circular_reveal_animation/circular_reveal_animation.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:whatsapp/data/models/user.dart';
// import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
// import 'package:whatsapp/presentation/pages/profile/profile_photo/profile_photo_page.dart';
// import 'package:whatsapp/utils/global.dart';

// class ProfilePhotoMini extends StatelessWidget {
//   const ProfilePhotoMini({
//     super.key,
//     required this.user,
//     this.onTapOutside,
//   });

//   final WhatsAppUser user;
//   final VoidCallback? onTapOutside;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.of(context).pop(),
//       child: Container(
//         color: Colors.black.withOpacity(0.4),
//         alignment: Alignment.topCenter,
//         padding: const EdgeInsets.only(top: 128),
//         child: SizedBox(
//           width: 250,
//           child: ProfilePhotoView(user: user),
//         ),
//       ),
//     );
//   }

//   Widget _buildIconButton(IconData icon, VoidCallback onTap) {
//     return IconButton(
//       onPressed: onTap,
//       icon: Icon(
//         icon,
//         color: Colors.teal,
//       ),
//     );
//   }
// }

// class ProfilePhotoView extends StatelessWidget {
//   const ProfilePhotoView({
//     super.key,
//     required this.user,
//     this.size = 250,
//   });

//   final WhatsAppUser user;
//   final double size;

//   @override
//   Widget build(BuildContext context) {
//     return Hero(
//       tag: user.phoneNo,
//       flightShuttleBuilder: (flightContext, animation, flightDirection,
//               fromHeroContext, toHeroContext) =>
//           AnimatedBuilder(
//         animation: animation,
//         builder: (context, child) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(24 * (animation.value <= 0.5 ? 1 : 0)),
//             child: Image.network(user.profileUrl ?? "#"),
//           );
//         },
//       ),
//       child: _buildWidget(context),
//     );
//   }

//   Material _buildWidget(BuildContext context) {
//     return Material(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Stack(
//             children: [
//               InkWell(
//                 onTap: _openFullPhoto,
//                 child: Image.network(
//                   user.profileUrl ?? "#",
//                   height: size,
//                   width: size,
//                 ),
//               ),
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 color: Colors.black.withOpacity(0.3),
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   user.name ?? user.phoneNo,
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             color: Theme.of(context).canvasColor,
//             width: MediaQuery.of(context).size.width,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildIconButton(
//                   WhatsAppIcons.message,
//                   () {},
//                 ),
//                 _buildIconButton(
//                   WhatsAppIcons.call,
//                   () {},
//                 ),
//                 _buildIconButton(
//                   WhatsAppIcons.videocam_rounded,
//                   () {},
//                 ),
//                 _buildIconButton(
//                   WhatsAppIcons.info_circle_fill_teal,
//                   () {},
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildIconButton(IconData icon, VoidCallback onTap,) {
//     return IconButton(
//       onPressed: onTap,
//       icon: Icon(
//         icon,
//         color: Colors.teal,
//       ),
//     );
//   }

//   void _openFullPhoto(BuildContext context) {
//     // Navigator.pop(context);
//     navigateWithoutTransition(context, ProfilePhotoPage(user: user));
//   }
// }
