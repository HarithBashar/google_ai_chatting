import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_ai_chat/app_data/app_data.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    loadChat();
  }

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
        // backgroundColor: Colors.redAccent,
        title: GestureDetector(
          onTap: () {
            if (kDebugMode) {
              for (int i = 0; i < controller.messages.length; i++) {
                print(controller.messages[i].message);
              }
            }
          },
          child: const Text(
            "Gemini PRO",
            // style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
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
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // to close the keyboard
            },
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background white.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: .05,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
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
                                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      decoration: BoxDecoration(
                                        color: isUser ? Colors.redAccent : Colors.white.withOpacity(.2),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: isUser ? const Radius.circular(10) : const Radius.circular(0),
                                          bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(10),
                                          topLeft: const Radius.circular(10),
                                          topRight: const Radius.circular(10),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isUser ? Colors.redAccent.withOpacity(.4) : Colors.white.withOpacity(.1),
                                            blurRadius: 50,
                                          )
                                        ],
                                      ),
                                      constraints: BoxConstraints(maxWidth: size.width * .8),
                                      child: Column(
                                        crossAxisAlignment: isUser? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            controller.messages[index].message.trim(),
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: isUser ? Colors.white : Colors.white,
                                            ),
                                            textDirection: detectLanguage(controller.messages[index].message[0]) == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(formatDateTime(controller.messages[index].timeSent, isDayShown: true), style: const TextStyle(fontSize: 12), textAlign: isUser ? TextAlign.right : TextAlign.left)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Ai Generation message
                                if (isAnswerGenerating && index == 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          margin: EdgeInsets.fromLTRB(5, 5, size.width * .2, 5),
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MessageBar(
                      onSend: (message) async {
                        message = message.trim();

                        if (message.isNotEmpty && !isAnswerGenerating) {
                          FocusScope.of(context).unfocus(); // to close the keyboard
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
                      messageBarColor: const Color(0xFF1D1C20).withOpacity(.4),
                      messageBarHintText: "Enter a message..",
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
