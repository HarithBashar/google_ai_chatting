import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:google_ai_chat/app_data/chat_class.dart';
import 'package:google_ai_chat/ui/chats/chats_class.dart';
import 'package:google_ai_chat/ui/chats/preview_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_data/constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});

  final ChatClass chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // AppData controller = Get.put(AppData(), permanent: true);
  ScrollController scrollController = ScrollController();
  bool isAnswerGenerating = false;

  @override
  void dispose() {
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> scrollToTop() async {
    try {
      if (scrollController.offset <= 0) return;
      await scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (_) {}
  }

  void scrollToMessage(double messageOffset) {
    try {
      scrollController.animateTo(
        messageOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() {
      if (scrollController.offset > 80) {
        setState(() => isScrollToTopButtonShown = true);
      } else if (scrollController.offset <= 0) {
        setState(() => isScrollToTopButtonShown = false);
      }
    });
  }

  bool isScrollToTopButtonShown = false;
  String selectedText = "";
  TextEditingController messageController = TextEditingController();
  String modelSelected = geminiModuleName;

  List<GlobalKey> messageKeys = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: isScrollToTopButtonShown
          ? Container(
              margin: const EdgeInsets.only(bottom: 55),
              child: CupertinoButton(
                child: Container(
                  height: 45,
                  width: 45,
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
                  child: Icon(Icons.keyboard_arrow_down_outlined, size: 25, color: Colors.white.withOpacity(.5)),
                ),
                onPressed: () {
                  scrollToTop();
                },
              ),
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        // backgroundColor: Colors.redAccent,
        title: Text(widget.chat.modelUsed == geminiModuleName ? "Gemini pro" : "chatGPT"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // background photo
          backgroundImage,

          // conversation
          Column(
            // alignment: Alignment.bottomCenter,
            children: [
              Expanded(
                child: widget.chat.messages.isNotEmpty
                    ? ListView.builder(
                        reverse: true,
                        controller: scrollController,
                        itemCount: widget.chat.messages.length,
                        itemBuilder: (context, index) {
                          bool isUser = widget.chat.messages[index].sender == 0;
                          messageKeys.add(GlobalKey());
                          return Column(
                            children: [
                              Container(
                                key: messageKeys[index],
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
                                child: Directionality(
                                  textDirection: getTextDirection(widget.chat.messages[index].message.trim()),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                widget.chat.messages[index].sender == 0
                                                    ? "You:"
                                                    : widget.chat.modelUsed == geminiModuleName
                                                        ? "Gemini: "
                                                        : "ChatGPT: ",
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFfdffd4))),
                                            DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                customButton: const Padding(
                                                  padding: EdgeInsets.only(bottom: 7),
                                                  child: Icon(
                                                    Icons.keyboard_control_rounded,
                                                    color: Colors.white30,
                                                  ),
                                                ),
                                                items: [
                                                  ...MenuItems.firstItems.map(
                                                    (item) => DropdownMenuItem<MenuItem>(
                                                      value: item,
                                                      child: MenuItems.buildItem(item),
                                                    ),
                                                  ),
                                                  // const DropdownMenuItem<Divider>(enabled: false, child: Divider()),
                                                ],
                                                onChanged: (value) {
                                                  MenuItems.onChanged(context, value!, widget.chat.messages[index].message.trim());
                                                },
                                                dropdownStyleData: DropdownStyleData(
                                                  width: 160,
                                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: const Color(0xFA1E1F22),
                                                  ),
                                                  offset: const Offset(0, 8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SelectionArea(
                                        child: MarkdownBody(
                                          // data: controller.messages[index].message.trim(),
                                          data: widget.chat.messages[index].message.trim(),
                                          styleSheet: MarkdownStyleSheet(
                                            h1: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFFfdffd4)),
                                            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFfdffd4)),
                                            h3: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFFfdffd4)),
                                            p: const TextStyle(fontSize: 17),
                                            strong: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFccfffa)),
                                            em: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFd4d5ff)),
                                            code: const TextStyle(
                                              backgroundColor: Color(0xFF141218),
                                              color: Colors.white,
                                              fontSize: 17,
                                            ),
                                          ),
                                          imageBuilder: (uri, title, alt) {
                                            // You can customize how the image looks using this imageBuilder
                                            return GestureDetector(
                                              onTap: () {
                                                Get.to(() => ImagePreviewScreen(imageUrl: uri.toString()));
                                              },
                                              child: CachedNetworkImage(
                                                imageUrl: uri.toString(),
                                                placeholder: (context, url) => LoadingAnimationWidget.staggeredDotsWave(
                                                  color: Colors.redAccent,
                                                  size: 40,
                                                ),
                                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                              ),
                                            );
                                          },
                                          onTapLink: (text, link, v) {
                                            launchUrl(Uri.parse(link ?? ""));
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(formatDateTime(widget.chat.messages[index].timeSent, isDayShown: true), style: const TextStyle(fontSize: 12))
                                    ],
                                  ),
                                ),
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
                                          Text("${widget.chat.modelUsed == geminiModuleName ? "Gemini" : "chatGPT"} is writing..."),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              if (index == 0) const SizedBox(height: 60),
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
                            const SizedBox(height: 25),
                            const Text(
                              "Unleash the conversation—pick your AI module...",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() => modelSelected = geminiModuleName);
                                    widget.chat.modelUsed = modelSelected;
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    width: size.width * .4,
                                    decoration: BoxDecoration(
                                      color: modelSelected == geminiModuleName ? mainColor.withOpacity(.5) : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                      border: Border.all(color: modelSelected == geminiModuleName ? Colors.transparent : Colors.grey[900]!),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      geminiModuleName,
                                      style: TextStyle(fontFamily: mainFont, color: modelSelected == geminiModuleName ? Colors.white : mainColor),
                                    ),
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() => modelSelected = chatGPTModuleName);
                                    widget.chat.modelUsed = modelSelected;
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    width: size.width * .4,
                                    decoration: BoxDecoration(
                                      color: modelSelected == chatGPTModuleName ? mainColor.withOpacity(.5) : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                                      border: Border.all(color: modelSelected == chatGPTModuleName ? Colors.transparent : Colors.grey[900]!),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      chatGPTModuleName,
                                      style: TextStyle(fontFamily: mainFont, color: modelSelected == chatGPTModuleName ? Colors.white : mainColor),
                                    ),
                                  ),
                                ),
                              ],
                            )
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
              SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF1f1d22))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF1f1d22))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF1f1d22))),
                            fillColor: const Color(0xFF1f1d22).withOpacity(.98),
                            filled: true,
                            hintText: 'Write a message...',
                          ),
                          maxLines: 5,
                          minLines: 1,
                          textDirection: getTextDirection(messageController.text.trim()),
                          onChanged: (x) => setState(() {}),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        String message = messageController.text.trim();
                        // if(kDebugMode) {
                        //   widget.chat.sendToChatGPT(message);
                        //   return;
                        // }
                        if (message.isNotEmpty && !isAnswerGenerating) {
                          messageController.clear();
                          FocusScope.of(context).unfocus(); // to close the keyboard

                          await scrollToTop();
                          // get the current tall offset of the list
                          // double currentOffset = scrollController.position.maxScrollExtent;
                          // print("Before: ${scrollController.position.maxScrollExtent}");

                          widget.chat.addMessage(message, 0); // user send a message
                          setState(() => isAnswerGenerating = true);

                          widget.chat.lastChatTime = DateTime.now();

                          // send to gemini or chatGPT.
                          if (widget.chat.modelUsed == geminiModuleName) {
                            await widget.chat.sendToGemini(message);
                          } else if (widget.chat.modelUsed == chatGPTModuleName) {
                            await widget.chat.sendToChatGPT(message);
                          }
                          setState(() => isAnswerGenerating = false);

                          // await scrollToTop();
                          // print("After: ${scrollController.position.maxScrollExtent}");
                          // print( "Result: ${currentOffset - scrollController.position.maxScrollExtent}");
                          // print(scrollController.position.maxScrollExtent - (scrollController.position.maxScrollExtent - currentOffset));
                          // scrollToMessage(currentOffset - scrollController.position.maxScrollExtent);

                          Get.put(ChatsClass()).refreshChats();
                        }
                      },
                      icon: const Icon(Icons.send),
                      color: isAnswerGenerating ? Colors.grey : Colors.redAccent,
                      splashColor: Colors.transparent,
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;
}

abstract class MenuItems {
  static const List<MenuItem> firstItems = [copyText, copyStyledText];

  static const copyText = MenuItem(text: 'Copy text', icon: Icons.copy_rounded);
  static const copyStyledText = MenuItem(text: 'Copy styled text', icon: Icons.copy_all_rounded);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  static void onChanged(BuildContext context, MenuItem item, String text) async {
    switch (item) {
      case MenuItems.copyText:
        text = text.replaceAll(RegExp(r'[*_~`#">+\-!\[\]()]'), '');
        text = text.trim();
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 70),
              backgroundColor: Color(0xCC1E1F22),
              content: Text(
                "Text Copied.",
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
      case MenuItems.copyStyledText:
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 70),
              backgroundColor: Color(0xCC1E1F22),
              content: Text(
                "Styled Text Copied.",
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        break;
    }
  }
}
