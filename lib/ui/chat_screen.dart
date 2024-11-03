import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_ai_chat/app_data/app_data.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_data/constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AppData controller = Get.put(AppData(), permanent: true);
  ScrollController scrollController = ScrollController();
  bool isAnswerGenerating = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Helper function to determine text direction
  TextDirection getTextDirection(String text) {
    text = text.replaceAll(RegExp(r'[*_~`#>+\-!\[\]\(\)]'), '');
    text = text.trim();

    if (text.isEmpty) return TextDirection.ltr;

    // RTL language character set (Arabic, Hebrew, etc.)
    final rtlLanguages = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u0590-\u05FF]');

    if (rtlLanguages.hasMatch(text)) {
      return TextDirection.rtl;
    } else {
      return TextDirection.ltr;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    loadChat();
    super.initState();

    scrollController.addListener(() {
      if (scrollController.offset != 0) {
        setState(() => isOffsetZero = false);
      } else {
        setState(() => isOffsetZero = true);
      }
    });
  }

  bool isOffsetZero = true;

  void loadChat() async {
    await controller.loadChat();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        // backgroundColor: Colors.redAccent,
        title: const Text("Gemini PRO"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              bool isAccepted = false;

              await Get.defaultDialog(
                title: "Delete chat?",
                middleText: "You will lose all the messages between you and AI, and start over!",
                onConfirm: () {
                  isAccepted = true;
                  Get.back();
                },
                onCancel: () {},
                textConfirm: '    delete    ',
                contentPadding: const EdgeInsets.all(15),
                buttonColor: Colors.redAccent,
                confirmTextColor: Colors.white,
              );

              if (isAccepted) {
                controller.messages.clear();
                GetStorage().erase();
                setState(() {});
              }
            },
            icon: const Icon(Icons.chat_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          // background photo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background white.png'),
                repeat: ImageRepeat.repeat,
                opacity: .05,
              ),
            ),
          ),

          // conversation
          Column(
            // alignment: Alignment.bottomCenter,
            children: [
              Expanded(
                child: controller.messages.isNotEmpty
                    ? ListView.builder(
                        reverse: true,
                        controller: scrollController,
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          bool isUser = controller.messages[index].sender == 0;

                          return Column(
                            children: [
                              Row(
                                // mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    margin: const EdgeInsets.symmetric(vertical: 15),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: isUser ? Colors.redAccent.withOpacity(.4) : Colors.white.withOpacity(.1),
                                          blurRadius: 50,
                                        )
                                      ],
                                    ),
                                    width: size.width,
                                    // constraints: BoxConstraints(maxWidth: size.width * .8),
                                    child: Directionality(
                                      textDirection: getTextDirection(controller.messages[index].message.trim()),
                                      child: Column(
                                        // crossAxisAlignment: isUser? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          SelectionArea(
                                            child: MarkdownBody(
                                              // data: controller.messages[index].message.trim(),
                                              data: controller.messages[index].message.trim(),
                                              styleSheet: MarkdownStyleSheet(
                                                h1: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFFfdffd4)),
                                                h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFfdffd4)),
                                                h3: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFFfdffd4)),
                                                p: const TextStyle(fontSize: 17),
                                                strong: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFccfffa)),
                                                em: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFd4d5ff)),
                                                code: const TextStyle(
                                                  // backgroundColor: Colors.grey[200],
                                                  color: Colors.white,
                                                ),
                                                // textDirection: detectLanguage(controller.messages[index].message[0]) == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                              ),
                                              onTapLink: (text, link, v) {
                                                launchUrl(Uri.parse(link ?? ""));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(formatDateTime(controller.messages[index].timeSent, isDayShown: true), style: const TextStyle(fontSize: 12))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Ai Generation message
                              if (isAnswerGenerating && index == 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        // color: Colors.white.withOpacity(.2),
                                        // borderRadius: const BorderRadius.only(
                                        //   bottomLeft: Radius.circular(0),
                                        //   bottomRight: Radius.circular(10),
                                        //   topLeft: Radius.circular(10),
                                        //   topRight: Radius.circular(10),
                                        // ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(.1),
                                            blurRadius: 50,
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              LoadingAnimationWidget.staggeredDotsWave(
                                                color: Colors.redAccent,
                                                size: 40,
                                              ),
                                              const SizedBox(width: 4),
                                              RotatedBox(
                                                quarterTurns: 2,
                                                child: LoadingAnimationWidget.staggeredDotsWave(
                                                  color: Colors.redAccent,
                                                  size: 40,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Text("Gemini is writing..."),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              if (index == 0) const SizedBox(height: 60),
                              // space in bottom
                              // Visibility(
                              //   visible: index == controller.messages.length - 1,
                              //   child: const SizedBox(
                              //     height: 70,
                              //   ),
                              // ),
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
              ),
            ],
          ),

          // send box
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isOffsetZero)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[800]!.withOpacity(.7),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.keyboard_arrow_down_outlined, size: 40, color: Colors.white),
                      ),
                      onPressed: () {
                        scrollToTop();
                      },
                    ),
                  ],
                ),
              SafeArea(
                top: false,
                child: MessageBar(
                  onSend: (message) async {
                    message = message.trim();

                    if (message.isNotEmpty && !isAnswerGenerating) {
                      FocusScope.of(context).unfocus(); // to close the keyboard
                      scrollToTop();
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
                  sendButtonColor: isAnswerGenerating ? Colors.grey : Colors.redAccent,
                  messageBarColor: Colors.transparent,
                  messageBarHintText: "Enter a message..",
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
