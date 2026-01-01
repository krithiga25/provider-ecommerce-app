import 'package:ecommerce_provider/views/shared/shared.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket socket;

  void connect(String token) {
    socket = io.io(
      url,
      io.OptionBuilder().setTransports(['websocket']).setAuth({
        'token': token,
      }).build(),
    );
    socket.connect();
  }

  void joinConversation(String conversationId) {
    socket.emit("join_conversation", {"conversationId": conversationId});
  }

  void sendProduct(String conversationId, String productId) {
    socket.emit("share_product", {
      "conversationId": conversationId,
      "productId": productId,
    });
  }

  void reactToProduct(String messageId, String reaction) {
    socket.emit("react_product", {
      "messageId": messageId,
      "reaction": reaction,
    });
  }
}
