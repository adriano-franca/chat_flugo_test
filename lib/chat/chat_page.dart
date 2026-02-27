import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../auth/login_page.dart';

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

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color indeedBlue = Color(0xFF2557A7);
    const Color backgroundColor = Color(0xFFF3F2F1);
    const Color borderColor = Color(0xFFD4D2D0);
    const Color textColor = Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mensagens",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: textColor),
            onPressed: logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: databaseRef.orderByChild("timestamp").onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final data = snapshot.data!.snapshot.value as Map?;

                if (data == null) {
                  return const Center(
                    child: Text(
                      "Nenhuma mensagem",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = data.entries.toList()
                  ..sort(
                    (a, b) =>
                        a.value["timestamp"].compareTo(b.value["timestamp"]),
                  );

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].value;
                    final isMe = message["userId"] == user!.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? indeedBlue : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: isMe ? null : Border.all(color: borderColor),
                        ),
                        child: Text(
                          message["text"],
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: isMe ? Colors.white : textColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: borderColor, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Escreva uma mensagem...",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: indeedBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: indeedBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
