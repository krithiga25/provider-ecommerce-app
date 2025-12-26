class FriendRequest {
  final String requestId;
  final String senderId;
  final String? receiverId;
  final String status;
  final String requesterEmail;

  FriendRequest({
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.requesterEmail,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      requestId: json['_id'],
      senderId: json['requester']['_id'],
      receiverId: json['receiver'],
      requesterEmail: json['requester']['email'],
      status: json['status'],
    );
  }
}