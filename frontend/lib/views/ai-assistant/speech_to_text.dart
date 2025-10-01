import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatInput extends StatefulWidget {
  final Function(String) onSend;

  const ChatInput({Key? key, required this.onSend}) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Type a message',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
          onPressed: _listen,
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSend(_controller.text.trim());
              _controller.clear();
            }
          },
        ),
      ],
    );
  }
}