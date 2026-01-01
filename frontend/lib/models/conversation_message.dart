import 'package:ecommerce_provider/models/product.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final Product product;
  final DateTime createdAt;
  final Map<String, List<String>> reactions;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.product,
    required this.createdAt,
    required this.reactions,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["_id"],
      conversationId: json["conversationId"],
      senderId: json["sender"],
      product: Product.fromJson(json["product"]),
      createdAt: DateTime.parse(json["createdAt"]),
      reactions: Map<String, List<String>>.from(
        (json["reactions"] ?? {}).map(
          (k, v) => MapEntry(k, List<String>.from(v)),
        ),
      ),
    );
  }

  void addReaction(String reaction, String userId) {
    reactions.putIfAbsent(reaction, () => []);
    if (!reactions[reaction]!.contains(userId)) {
      reactions[reaction]!.add(userId);
    }
  }
}

class Conversation {
  final String id;
  final List<Participants> participants;
  final Message? lastMessageAt;

  Conversation({
    required this.id,
    required this.participants,
    this.lastMessageAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'],
      participants:
          (json['participants'] as List)
              .map((u) => Participants.fromJson(u))
              .toList(),
    );
  }
}

class Participants {
  final String id;
  final String name;
  final String email;

  Participants({required this.id, required this.name, required this.email});
  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      id: json['_id'],
      name: json['userName'],
      email: json['email'],
    );
  }
}
