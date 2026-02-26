import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageController = TextEditingController();
  final databaseRef = FirebaseDatabase.instance.ref("messages");
  final user = FirebaseAuth.instance.currentUser;

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    databaseRef.push().set({
      "text": messageController.text.trim(),
      "userId": user!.uid,
      "email": user!.email,
      "timestamp": ServerValue.timestamp,
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Flugo Test")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: databaseRef.orderByChild("timestamp").onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final data = snapshot.data!.snapshot.value as Map?;

                if (data == null) return const SizedBox();

                final messages = data.entries.toList()
                  ..sort(
                    (a, b) =>
                        a.value["timestamp"].compareTo(b.value["timestamp"]),
                  );

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].value;
                    final isMe = message["userId"] == user!.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message["text"],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(hintText: "Mensagem"),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}
