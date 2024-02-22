import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_app/constants.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User? _loggedinUser;
  String? textMessage = 'hello';

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController messageController = TextEditingController();

  getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      _loggedinUser = user;
      print(_loggedinUser!.email);
    }
  }
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<dynamic> messagesList = snapshot.data!.docs;
                  // List<Widget> messageWidgets = [];
                  // for (var message in messagesList) {
                  //   final messageSender = message['sender'];
                  //   final messageText = message['text'];
                  //   final isMe = messageSender == _loggedinUser!.email; //false
                  //
                  //   messageWidgets.add(
                  //     MessageBubble(
                  //       text: messageText,
                  //       sender: messageSender,
                  //       isMe: isMe, //true//false
                  //     ),
                  //   );
                  // }
                  // return Expanded(
                  //   child: ListView(
                  //     reverse: false,
                  //     shrinkWrap: true,
                  //     padding: EdgeInsets.all(10),
                  //     children: messageWidgets,
                  //   ),
                  // );
                  return Expanded(
                    child: ListView.builder(
                      itemCount: messagesList.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          text: messagesList[index]['text'],
                          sender: messagesList![index]['sender'],
                          isMe: _loggedinUser!.email ==
                              messagesList![index]['sender'], //true//false
                        );
                      },
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        //Do something with the user input.
                        textMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      //Implement send functionality.
                      messageController.clear();
                      try {
                        final data = {
                          "sender": _loggedinUser!.email!,
                          "text": textMessage ?? 'empty'
                        };
                        await firestore.collection('messages').add(data);
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? text;
  final String? sender;
  final bool? isMe;
  MessageBubble(
      {@required this.text, @required this.sender, @required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender!,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isMe!
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
            // BorderRadius.circular(30),
            color: isMe! ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                text!,
                style: TextStyle(
                    fontSize: 15, color: isMe! ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
