import 'package:ecommerce_provider/models/conversation_message.dart';
import 'package:ecommerce_provider/providers/friend_request_provider.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:ecommerce_provider/views/shop_with_friends/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendsConnection extends StatefulWidget {
  const FriendsConnection({super.key});

  @override
  State<FriendsConnection> createState() => _FriendsConnectionState();
}

class _FriendsConnectionState extends State<FriendsConnection> {
  late SharedPreferences prefs;
  String email = '';
  @override
  void initState() {
    super.initState();
  }

  void _getCurrentUser() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('currentuser')!;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    return Consumer<FriendRequestProvider>(
      builder: (context, connectionsProvider, child) {
        final friendRequests = connectionsProvider.friendRequests;
        return Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final chatProvider = Provider.of<ChatProvider>(
              context,
              listen: false,
            );
            return Scaffold(
              backgroundColor: Color(0xFFF7F7F7),
              appBar: AppBar(
                backgroundColor: Color(0xFFF7F7F7),

                title: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    'Connections',
                    style: GoogleFonts.openSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade500,
                    ),
                  ),
                ),
              ),
              body: RefreshIndicator(
                backgroundColor: Colors.blueGrey,
                color: Colors.white,
                onRefresh: () async {
                  await Provider.of<FriendRequestProvider>(
                    context,
                    listen: false,
                  ).fetchFriendRequests();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.all(16),
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 20),
                            Container(
                              height: 48,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  ' Send Request ',
                                  style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                cursorColor: Colors.blueGrey,
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  focusColor: Colors.blueGrey,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.flight_takeoff_outlined),
                                    color: Colors.blueGrey,
                                    onPressed:
                                        () => {
                                          connectionsProvider.sendRequest(
                                            controller.text,
                                          ),
                                          focusNode.unfocus(),
                                          controller.clear(),
                                        },
                                  ),
                                  hintText: 'Enter Code',
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requests Received',
                              style: GoogleFonts.openSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey.shade500,
                              ),
                            ),
                            if (friendRequests.isEmpty) ...[
                              SizedBox(height: 10),
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'No Connection Requests\n     (refresh to check!)',
                                    style: GoogleFonts.openSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((ctx, index) {
                        final connection = friendRequests[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            title: Text(
                              connection.requesterName,
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                            subtitle: Text(
                              'Wants to connect with you',
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Accept',
                                    style: GoogleFonts.openSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final bool status =
                                        await connectionsProvider.acceptRequest(
                                          connection.requestId,
                                          index,
                                        );
                                    Future.delayed(
                                      Duration(milliseconds: 500),
                                      () {
                                        if (!mounted) return;
                                        showCustomSnackBar(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          status
                                              ? "Connection Accepted!"
                                              : "Failed to connect. Try again.",
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: friendRequests.length),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final Conversation conversationIds =
                              connectionsProvider.conversationIds[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              title: Text(
                                conversationIds.participants[0].email == email
                                    ? conversationIds.participants[1].name
                                    : conversationIds.participants[0].name,
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                              subtitle: Text(
                                'Tap to join chat',
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.blueGrey,
                              ),
                              onTap: () {
                                chatProvider.connectAndJoin(
                                  token: connectionsProvider.token,
                                  conversationId: conversationIds.id,
                                );
                                chatProvider.getMessages(conversationIds.id);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => FriendsChatScreen(
                                          requesterId:
                                              conversationIds
                                                  .participants[1]
                                                  .name,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: connectionsProvider.conversationIds.length,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
