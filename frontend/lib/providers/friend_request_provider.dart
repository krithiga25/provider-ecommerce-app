import 'dart:convert';

import 'package:ecommerce_provider/models/friend_requests.dart';
import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendRequestProvider with ChangeNotifier {
  List<FriendRequest> _friendRequests = [];
  late String token = '';

  List<FriendRequest> get friendRequests {
    return [..._friendRequests];
  }

  Future<void> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token')!;
  }

  Future<void> sendRequest(usercode) async {
    await getUserToken();
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
    _friendRequests.removeAt(index);
    notifyListeners();
    if (response.statusCode == 200) {
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
