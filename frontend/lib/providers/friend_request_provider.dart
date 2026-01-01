import 'dart:convert';
import 'package:ecommerce_provider/models/conversation_message.dart';
import 'package:ecommerce_provider/models/friend_requests.dart';
import 'package:ecommerce_provider/models/socket_io.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendRequestProvider with ChangeNotifier {
  List<FriendRequest> _friendRequests = [];
  List<Conversation> _conversationIds = [];
  late String token = '';

  List<FriendRequest> get friendRequests {
    return [..._friendRequests];
  }

  List<Conversation> get conversationIds {
    return [..._conversationIds];
  }

  Future<void> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
  }

  Future<void> sendRequest(usercode) async {
    await http.post(
      Uri.parse("$url/friends/connect"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"friendCode": "$usercode"}),
    );
  }

  Future<void> fetchFriendRequests() async {
    await getUserToken();
    final response = await http.get(
      Uri.parse('$url/friends/requests'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    final data = jsonDecode(response.body);
    _friendRequests =
        (data['requests'] as List)
            .map((e) => FriendRequest.fromJson(e))
            .toList();

    final conversationIds = await http.get(
      Uri.parse('$url/friends/conversationIds'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    final reqData = jsonDecode(conversationIds.body);
    _conversationIds =
        (reqData['requests'] as List)
            .map((e) => Conversation.fromJson(e))
            .toList();
    notifyListeners();
  }

  Future<bool> acceptRequest(String requestId, int index) async {
    final response = await http.post(
      Uri.parse("$url/friends/accept"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"requestId": requestId}),
    );
    notifyListeners();
    if (response.statusCode == 200) {
      _friendRequests.removeAt(index);
      return true;
    } else {
      return false;
    }
  }

  Future<void> declineRequest(String requestId, int index) async {
    await http.post(
      Uri.parse("$url/friends/decline"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"requestId": requestId}),
    );
    _friendRequests.removeAt(index);
    notifyListeners();
  }
}

class ChatProvider with ChangeNotifier {
  final SocketService socketService;
  final List<Message> _messages = [];
  bool messagesRetrieved = false;

  List<Message> get messages {
    return [..._messages];
  }

  ChatProvider(this.socketService);

  Future<void> getMessages(String conversationId) async {
    //if (messagesRetrieved) return;
    _messages.clear();
    final response = await http.get(
      Uri.parse('$url/friends/conversation/$conversationId'),
    );
    final data = jsonDecode(response.body);
    final requests = data['requests'];
    for (var request in requests) {
      final message = Message.fromJson(request);
      _messages.add(message);
      print(message.reactions['heart']);
    }
    messagesRetrieved = true;
    notifyListeners();
  }

  void connectAndJoin({required String token, required String conversationId}) {
    socketService.connect(token);
    socketService.joinConversation(conversationId);
    initSocketListeners();
  }

  void initSocketListeners() {
    socketService.socket.on("new_message", (data) {
      _messages.add(Message.fromJson(data));
      notifyListeners();
    });
    socketService.socket.on("reaction_update", (data) {
      final msg = _messages.firstWhere((m) => m.id == data["messageId"]);
      msg.addReaction(data["reaction"], data["userId"]);
      notifyListeners();
    });
  }

  void sendProduct(String conversationId, String productId) {
    socketService.sendProduct(conversationId, productId);
  }

  void react(String messageId, String reaction) {
    socketService.reactToProduct(messageId, reaction);
  }
}
