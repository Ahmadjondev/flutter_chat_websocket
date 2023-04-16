import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController chatText = TextEditingController();
  List messages = [];
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _channel =
        IOWebSocketChannel.connect(Uri.parse('ws://192.168.220.96:8000/chat'));
    _channel.stream.listen(
      (event) {
        print(event);
        setState(() {
          messages.add(event);
        });
      },
      onDone: () {
        debugPrint('ws channel closed');
      },
      onError: (error) {
        debugPrint('ws error $error');
      },
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('${messages[index]}'),
              ),
            ),
          ),
          TextField(
            controller: chatText,
            // onSubmitted: _sendMessage,
            decoration: InputDecoration(
              hintText: 'Enter a message',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  _channel.sink.add(chatText.text);
                  chatText.clear();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
