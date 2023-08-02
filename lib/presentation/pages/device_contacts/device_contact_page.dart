import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/bloc/chatting/chats_bloc.dart';
import 'package:whatsapp/bloc/contacts/contacts_bloc.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/data/repository/contacts_repository.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/chatting/chatting_page.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';
import 'package:whatsapp/utils/global.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class DeviceContactsPage extends StatefulWidget {
  const DeviceContactsPage({super.key});

  @override
  State<DeviceContactsPage> createState() => _DeviceContactsPageState();
}

class _DeviceContactsPageState extends State<DeviceContactsPage> {
  @override
  Widget build(BuildContext context) {
    // BlocProvider.of<ChattingBloc>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Select contacts")),
        body: RepositoryProvider(
          create: (context) => ContactsRepository(),
          child: BlocProvider(
            create: (context) =>
                ContactsBloc(RepositoryProvider.of<ContactsRepository>(context))
                  ..add(LoadContactsEvent()),
            child: CustomScrollView(
              slivers: [
                _buildNewTile("New group", WhatsAppIcons.group, () {}),
                _buildNewTile("New contact", Icons.person_add_rounded, () {}),
                _buildNewTile("New community", WhatsAppIcons.community, () {}),
                _buildHeader("Contacts on WhatsApp"),
                BlocBuilder<ContactsBloc, ContactsState>(
                  builder: (context, state) {
                    if (state is ContactsLoadingState) {
                      return _buildLoadingContacts();
                    }

                    if (state is ContactsLoadedState) {
                      return _buildUserList(state.whatsappUsers);
                    }

                    if (state is ContactsErrorState) {
                      return _buildError(state.error);
                    }

                    return _buildError("No state");
                  },
                ),
                _buildHeader("Invite to WhatsApp"),
                BlocBuilder<ContactsBloc, ContactsState>(
                  builder: (context, state) {
                    if (state is ContactsLoadingState) {
                      return _buildLoadingTiles(5);
                    }

                    if (state is ContactsLoadedState) {
                      return _buildLoadingTiles(5);
                      // return _buildInviteContacts(state.otherContacts);
                    }

                    if (state is ContactsErrorState) {
                      return _buildError(state.error);
                    }

                    return _buildError("No state");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewTile(String title, IconData iconData, onTap) {
    return SliverToBoxAdapter(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(
            iconData,
            color: Colors.white,
          ),
        ),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInviteContacts(List<Contact> data) {
    return data.isNotEmpty
        ? SliverList.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueGrey,
                foregroundImage: AssetImage(AssetImages.default_profile),
              ),
              title: Text(
                data[index].displayName ??
                    data[index].phones?.first.value ??
                    "Unknown",
              ),
              trailing: TextButton(
                child: const Text("Invite"),
                onPressed: () {},
              ),
            ),
          )
        : _buildEmptyMessagge("No contacts");
  }

  Widget _buildHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 120,
        child: Center(
          child: Text(
            error,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContacts() {
    return const SliverToBoxAdapter(
      child: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  Widget _buildEmptyMessagge(String message) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 120,
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<WhatsAppUser> users) {
    return users.isNotEmpty
        ? SliverList.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => ListTile(
              onTap: () => _openCoversation(users[index]),
              leading: ProfilePhoto(
                size: 40,
                placeholderPath: AssetImages.default_profile,
                imageUrl: users[index].photoUrl ?? "#",
                //imageErrorBuilder: (context, error, stackTrace) => Image.asset(AssetImages.default_profile),
              ),
              title: Text(users[index].name ?? users[index].phoneNo),
            ),
          )
        : _buildEmptyMessagge("No contacts.");
  }

  Widget _buildLoadingTiles(int count) {
    double offset = 30;
    return SliverList.builder(
      itemCount: count,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        title: ShaderMask(
          blendMode: BlendMode.srcATop,
          
          shaderCallback: (bounds) {
            return LinearGradient(colors: [
            Theme.of(context).colorScheme.surface,
            Colors.grey[300] ?? Colors.grey,
                        Theme.of(context).colorScheme.surface,

          ]).createShader(Rect.fromLTWH(bounds.top+offset, bounds.left+offset, bounds.width / 3, bounds.height));
          },
          child: Container(
            height: 16,
            width: 30,
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0)
            ),
          ),
        ),
      ),
    );
  }

  void _openCoversation(WhatsAppUser user) async {
    Navigator.pop<bool>(
        context,
        await navigateTo<bool>(
          context,
          BlocProvider.value(
                value: BlocProvider.of<ChattingBloc>(context),
                child: ChattingPage(
                  user: user,
                ),
              ),
        ));
  }
}
