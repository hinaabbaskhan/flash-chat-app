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
            StreamBuilder(
              stream: firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messagesList = snapshot.data!.docs.reversed;

                  List<Widget> messageWidgets = [];
                  for (var message in messagesList) {
                    final messageSender = message['sender'];
                    final messageText = message['text'];
                    final isMe = messageSender == _loggedinUser!.email; //false

                    messageWidgets.add(
                      MessageBubble(
                        text: messageText,
                        sender: messageSender,
                        isMe: isMe, //true//false
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView(
                      reverse: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(10),
                      children: messageWidgets,
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
