import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/providers/friend_request_provider.dart';
import 'package:ecommerce_provider/views/products/single_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FriendsChatScreen extends StatefulWidget {
  const FriendsChatScreen({super.key, required this.requesterId});
  final String requesterId;
  @override
  State<FriendsChatScreen> createState() => _FriendsChatScreenState();
}

class _FriendsChatScreenState extends State<FriendsChatScreen> {
  bool longPressed = false;
  OverlayEntry? _reactionOverlay;
  @override
  void dispose() {
    _reactionOverlay?.remove();
    _reactionOverlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Consumer<FriendRequestProvider>(
          builder: (context, friendRequestProvider, child) {
            final userId =
                friendRequestProvider.conversationIds[0].participants[1].id;
            final chatProvider = Provider.of<ChatProvider>(
              context,
              listen: false,
            );
            return Scaffold(
              backgroundColor: Color(0xFFF7F7F7),
              appBar: AppBar(
                title: Text(
                  widget.requesterId,
                  style: GoogleFonts.openSans(color: Colors.blueGrey[500]),
                ),
                backgroundColor: Color(0xFFF7F7F7),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                height: 70,
                child: Center(
                  child: Text(
                    "Checkout products page to share the products!",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.blueGrey[300],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              body: CustomScrollView(
                slivers: [
                  if (chatProvider.messages.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          "No messages yet. Start sharing products!",
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.blueGrey[300],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, index) {
                      final message = chatProvider.messages[index];
                      return Align(
                        alignment:
                            userId == message.senderId
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPressStart: (details) {
                            // print(message.reactions);
                            // setState(() {
                            //   longPressed = !longPressed;
                            // });
                            _showReactionOverlay(
                              context,
                              details.globalPosition,
                              chatProvider,
                              chatProvider.messages[index].id,
                            );
                          },
                          onTapDown: (_) {
                            _reactionOverlay?.remove();
                            _reactionOverlay = null;
                          },
                          onDoubleTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => SingleProductScreen(
                                      id: message.product.id,
                                    ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  top: 10,
                                  right: 20,
                                  bottom: 10,
                                  left: 20,
                                ),
                                width: 200,
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft:
                                        message.senderId == userId
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                    bottomRight:
                                        message.senderId == userId
                                            ? Radius.zero
                                            : const Radius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: CachedNetworkImage(
                                          imageUrl: message.product.imageUrl,
                                          fit: BoxFit.fitWidth,
                                          height: 120,
                                        ),
                                      ),
                                      Text(
                                        message.product.title,
                                        style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Row(
                                            children: List.generate(
                                              5,
                                              (index) => Icon(
                                                index < message.product.rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color:
                                                    index <
                                                            message
                                                                .product
                                                                .rating
                                                        ? Colors.yellow
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '(${message.product.ratingCount.toString()})',
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '\u{20B9} ${message.product.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (message.reactions['heart'] != null &&
                                      message.reactions['heart']!.isNotEmpty ||
                                  message.reactions['thumbsUp'] != null &&
                                      message
                                          .reactions['thumbsUp']!
                                          .isNotEmpty ||
                                  message.reactions['thumbsDown'] != null &&
                                      message
                                          .reactions['thumbsDown']!
                                          .isNotEmpty)
                                Positioned(
                                  bottom: 0,
                                  left: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          offset: Offset(0, 1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            _getTopReaction(message.reactions)!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: chatProvider.messages.length),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReactionOverlay(
    BuildContext context,
    Offset position,
    ChatProvider chatProvider,
    String messageId,
  ) {
    _reactionOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx,
          top: position.dy - 50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    chatProvider.react(messageId, 'heart');
                    _reactionOverlay?.remove();
                    _reactionOverlay = null;
                  },
                  child: Text("❤️"),
                ),
                TextButton(
                  onPressed: () {
                    chatProvider.react(messageId, 'thumbsUp');
                    _reactionOverlay?.remove();
                    _reactionOverlay = null;
                  },
                  child: Text("👍"),
                ),
                TextButton(
                  onPressed: () {
                    chatProvider.react(messageId, 'thumbsDown');
                    _reactionOverlay?.remove();
                    _reactionOverlay = null;
                  },
                  child: Text("👎"),
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_reactionOverlay!);
  }

  String? _getTopReaction(Map<String, List<String>> reactions) {
    if ((reactions['heart'] ?? []).isNotEmpty) return "❤️";
    if ((reactions['thumbsUp'] ?? []).isNotEmpty) return "👍";
    if ((reactions['thumbsDown'] ?? []).isNotEmpty) return "👎";
    return null;
  }

  Widget _reactionChip(String emoji, int count) {
    return Container(
      margin: EdgeInsets.only(right: 6),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [Text(emoji), SizedBox(width: 4), Text(count.toString())],
      ),
    );
  }
}
