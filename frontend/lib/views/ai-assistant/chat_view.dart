//import 'package:ecommerce_provider/views/ai-assistant/three_bounce.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_provider/providers/product_provider.dart';
import 'package:ecommerce_provider/views/login_register/profile.dart';
import 'package:ecommerce_provider/views/orders_payment/orders_screen.dart';
import 'package:ecommerce_provider/views/products/single_product_screen.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final List<String> _suggestions = [
    "How to change dark theme?",
    "When will I get my orders?",
    "Things to remember before buying laptop",
  ];

  void _handleSend(String message) async {
    setState(() {
      _messages.add(Message(text: message, isUser: true));
      print(_messages.length);
      _messages.add(Message(text: "", isUser: false, isTyping: true));
    });
    try {
      final botResponse = await _getBotReply(message);
      final category = botResponse['category'];
      final answer = botResponse['answer'];
      setState(() {
        _messages.removeWhere((msg) => msg.isTyping);
        if (category == 'products' && answer != null) {
          _messages.add(
            Message(
              text: answer['summary'] ?? '',
              isUser: false,
              queryType: 'products',
              productIds: List<String>.from(answer['products'] ?? []),
            ),
          );
        } else {
          _messages.add(
            Message(
              text:
                  answer is String
                      ? answer
                      : (answer['summary'] ?? 'No answer found'),
              isUser: false,
              queryType: category,
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg.isTyping);
        _messages.add(
          Message(text: "Sorry, something went wrong 😕", isUser: false),
        );
      });
    }
  }

  Future<Map<String, dynamic>> _getBotReply(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('$url/ask'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": userMessage}),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];
        return {
          'category': data['category'] ?? 'default',
          'answer': data['answer'] ?? {},
        };
      } else {
        throw Exception('Failed to get response from server');
      }
    } catch (e) {
      throw Exception("Error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/robo_nobackground.png', height: 60),
                  const SizedBox(height: 8),
                  Text(
                    "Hi, I'm Nemo",
                    style: GoogleFonts.openSans(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Ask me anything - I'm here to help!",
                    style: GoogleFonts.openSans(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      wordSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _messages.isEmpty
                    ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _suggestions.map((s) {
                              return GestureDetector(
                                onTap: () => _handleSend(s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.blueGrey),
                                  ),
                                  child: Text(
                                    s,
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        //final formattedText = _formatText(message.text);
                        if (message.isTyping) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: SpinKitThreeBounce(
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                          );
                        }
                        Widget messageContent;
                        switch (message.queryType) {
                          case 'products':
                            messageContent = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text,
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildProductList(
                                  context,
                                  message.productIds ?? [],
                                ),
                              ],
                            );
                            break;
                          case 'faq_orders_returns_shipping':
                            messageContent = Column(
                              children: [
                                _messageContent(context, message),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => OrdersPage(),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.blueGrey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        "View Orders",
                                        style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                            break;
                          case 'faq_account_settings':
                            messageContent = Column(
                              children: [
                                _messageContent(context, message),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(),//error
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.blueGrey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        "View Profile",
                                        style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                            break;
                          case 'faq_payment_methods':
                          case 'general':
                            messageContent = _messageContent(context, message);
                            break;
                          default:
                            messageContent = Text(
                              message.text,
                              style: GoogleFonts.openSans(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            );
                        }
                        return Align(
                          alignment:
                              message.isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  message.isUser
                                      ? Colors.blueGrey[100]
                                      : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft:
                                    message.isUser
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                bottomRight:
                                    message.isUser
                                        ? Radius.zero
                                        : const Radius.circular(12),
                              ),
                            ),
                            child: messageContent,
                          ),
                        );
                      },
                    ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChatInput(onSend: _handleSend),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageContent(context, Message message) {
    return MarkdownBody(
      data: message.text,
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.openSans(
          fontSize: 15,
          color: Colors.blueGrey,
          fontWeight: FontWeight.w600,
        ),
        listBullet: const TextStyle(fontSize: 18, color: Colors.blueGrey),
        strong: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProductList(
    BuildContext parentContext,
    List<String> productIds,
  ) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final products = productProvider.products;
        final filteredProducts =
            products.where((p) => productIds.contains(p.id)).toList();
        return Column(
          children:
              filteredProducts.map((product) {
                return Card(
                  color: const Color(0xFFF7F7F7),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      height: 60,
                      width: 60,
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      product.title,
                      style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("₹${product.price.toStringAsFixed(2)}"),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.of(parentContext).push(
                        MaterialPageRoute(
                          builder:
                              (context) => SingleProductScreen(id: product.id),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final bool isTyping;
  final String? queryType;
  final List<String>? productIds;

  Message({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.queryType,
    this.productIds,
  });
}
