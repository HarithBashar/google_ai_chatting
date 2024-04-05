import 'dart:ui';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_ai_chat/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AppData controller = Get.put(AppData(), permanent: true);
  ScrollController scrollController = ScrollController();
  bool isAnswerGenerating = false;

  void slideDown() {
    if (controller.messages.length > 2) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  String detectLanguage(String string) {
    String languageCodes = 'en';

    final RegExp english = RegExp(r'^[a-zA-Z]+');
    final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');

    if (arabic.hasMatch(string)) languageCodes = 'ar';
    if (english.hasMatch(string)) languageCodes = 'en';

    return languageCodes;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(() {});
    loadChat();
  }

  void loadChat() async {
    await controller.loadChat();
    setState(() {});

    await Future.delayed(const Duration(seconds: 1));
    slideDown();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // backgroundColor: Colors.redAccent,
        title: const Text(
          "Gemini PRO",
          // style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              controller.messages.clear();
              pref.clear();
              setState(() {});
              slideDown();
            },
            icon: const Icon(Icons.chat_outlined),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          controller.messages.isNotEmpty
              ? ListView.builder(
                  controller: scrollController,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {

                    bool isUser = controller.messages[index].sender == 0;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.redAccent
                                    : Colors.white.withOpacity(.2),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: isUser
                                      ? const Radius.circular(10)
                                      : const Radius.circular(0),
                                  bottomRight: isUser
                                      ? const Radius.circular(0)
                                      : const Radius.circular(10),
                                  topLeft: const Radius.circular(10),
                                  topRight: const Radius.circular(10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isUser
                                        ? Colors.redAccent.withOpacity(.4)
                                        : Colors.white.withOpacity(.1),
                                    blurRadius: 50,
                                  )
                                ],
                              ),
                              constraints: BoxConstraints(maxWidth: size.width * .8),
                              child: SelectableText(
                                controller.messages[index].message,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: isUser ? Colors.white : Colors.white,
                                ),
                                textDirection: detectLanguage(controller
                                            .messages[index].message[0]) ==
                                        'ar'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                              ),
                            ),
                          ],
                        ),
                        // Ai Generation message
                        Visibility(
                          visible: isAnswerGenerating &&
                              index == controller.messages.length - 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  margin: EdgeInsets.fromLTRB(
                                      5, 5, size.width * .2, 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.2),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(.05),
                                        blurRadius: 50,
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      LoadingAnimationWidget.staggeredDotsWave(
                                        color: Colors.redAccent,
                                        size: 40,
                                      ),
                                      const Text("Generating Answer"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // space in bottom
                        Visibility(
                          visible: index == controller.messages.length - 1,
                          child: const SizedBox(
                            height: 70,
                          ),
                        )
                      ],
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * .6,
                        child: Image.asset('assets/icons/chat.png'),
                      ),
                      Text(
                        "Send a message to start chatting...",
                        style: TextStyle(fontSize: size.width * .05),
                      ),
                    ],
                  ),
                ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MessageBar(
                onSend: (message) async {

                  message = message.trim();

                  if (message.isNotEmpty && !isAnswerGenerating) {
                    FocusScope.of(context).unfocus(); // to close the keyboard
                    slideDown(); // Scrolling to the end of the list
                    controller.addMessage(message, 0); // user send a message
                    setState(() {
                      isAnswerGenerating = true;
                    });

                    await controller.sendMessage(message);
                    setState(() {
                      isAnswerGenerating = false;
                    });
                  }

                },
                sendButtonColor:
                    isAnswerGenerating ? Colors.grey : Colors.redAccent,
                messageBarColor: const Color(0xFF1D1C20).withOpacity(.4),
                messageBarHintText: "Enter a message..",
              ),
            ],
          )
        ],
      ),
    );
  }
}
