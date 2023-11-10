import 'dart:convert';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _textController = TextEditingController();

  //for showing emoji / hiding
  bool _showEmoji = false;

  List<Message> _list = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() => _showEmoji = !_showEmoji);
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
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
                    image: Theme.of(context).colorScheme.brightness ==
                            Brightness.light
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
                            return const SizedBox();

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
                                  reverse: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    return MessageCard(
                                      message: _list[index],
                                    );
                                  });
                            } else {
                              return Center(
                                  child: TextButton(
                                      onPressed: () {
                                        _textController.text = 'Hii 👋';
                                      },
                                      child: const Text('Say Hii 👋',
                                          style: TextStyle(fontSize: 18))));
                            }
                        }
                      }),
                ),
                _chatInputs(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: Theme.of(context).colorScheme.background,
                        columns: 7,
                        emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(mq.width * .011),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _showEmoji = !_showEmoji);
                        },
                        icon: const Icon(Icons.emoji_emotions_outlined)),
                    Expanded(
                        child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type message here'),
                    )),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();

                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (image != null) {
                            print('Image path : ${image.path}');
                            await APISystem.sentImage(
                                widget.user, File(image.path));
                          }
                        },
                        icon: const Icon(Icons.camera_alt)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  APISystem.sendMessage(
                      widget.user, _textController.text, Type.text);
                  _textController.text = '';
                }
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.send),
            ),
          )
        ],
      ),
    );
  }
}
