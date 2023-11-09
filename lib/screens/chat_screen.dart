import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mess_app/api/api_system.dart';
import 'package:mess_app/main.dart';
import 'package:mess_app/models/message.dart';
import 'package:mess_app/models/user_chat.dart';
import 'package:mess_app/themes/light_theme.dart';
import 'package:mess_app/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final UserChat user;
  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: mq.height * 0.034),
          child: _appBar(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image:
                    Theme.of(context).colorScheme.brightness == Brightness.light
                        ? const AssetImage('images/bglight.png')
                        : const AssetImage('images/bgDark.jpg'),
                fit: BoxFit.cover)),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: APISystem.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //when data loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );

                      //when all data is loaded
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        // print('data ${jsonEncode(data![0].data())}');

                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              });
                        } else {
                          return const Center(
                            child: Text(
                              'Say Hii 👋',
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }
                    }
                  }),
            ),
            _chatInputs(),
          ],
        ),
      ),
    );
  }

  Widget? _appBar() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        widget.user.image.isEmpty
            ? CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                radius: 20,
                child: Center(
                  child: Text(
                    widget.user.name[0],
                    style: TextStyle(fontSize: 25, color: Colors.grey[800]),
                  ),
                ),
              )
            : CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
        SizedBox(
          width: mq.width * 0.028,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              'Last seen not available',
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ],
        )
      ],
    );
  }

  Widget _chatInputs() {
    return Padding(
      padding: EdgeInsets.all(mq.width * .01),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(mq.width * .01),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.emoji_emotions_outlined)),
                    const Expanded(
                        child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type message here'),
                    )),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.camera_alt)),
                  ],
                ),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
