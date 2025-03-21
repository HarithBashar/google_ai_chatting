import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_ai_chat/app_data/chat_class.dart';
import 'package:google_ai_chat/app_data/constants.dart';
import 'package:google_ai_chat/app_data/my_dialogs.dart';
import 'package:google_ai_chat/ui/chats/chats_class.dart';
import 'package:google_ai_chat/ui/chats/chat_screen.dart';
import 'package:google_ai_chat/ui/settings/settings.dart';

class AllChats extends StatefulWidget {
  const AllChats({super.key});

  @override
  State<AllChats> createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() {
      if (scrollController.offset >= 66) {
        setState(() => isAddButtonShow = true);
      } else if (scrollController.offset <= 50) {
        setState(() => isAddButtonShow = false);
      }
    });
  }

  void scrollToTop() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool isAddButtonShow = false;

  ChatsClass controller = Get.put(ChatsClass(), permanent: true);

  void startNewChat() async {
    controller.allChats.add(ChatClass(messages: [], title: '', startChatTime: DateTime.now(), lastChatTime: DateTime.now(), id: generateId(), modelUsed: geminiModuleName));
    await Get.to(() => ChatScreen(chat: controller.allChats.last));
    Get.put(ChatsClass()).deleteEmptyChats();
  }

  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: isAddButtonShow
          ? FloatingActionButton(
              backgroundColor: Colors.blueGrey[900]?.withOpacity(.9),
              onPressed: () {
                _removeOverlay();
                startNewChat();
              },
              child: const Icon(Icons.add, color: Colors.blueGrey),
            )
          : null,
      appBar: AppBar(
        title: GestureDetector(
          child: const Text("All Chats"),
          onTap: () {
            scrollToTop();
          },
        ),
        automaticallyImplyLeading: true,
        forceMaterialTransparency: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const Settings());
            },
            icon: const Icon(Icons.settings_rounded),
            color: Colors.white60,
          ),
        ],
      ),
      body: Stack(
        children: [
          backgroundImage,
          GetBuilder(
              init: ChatsClass(),
              builder: (controller) {
                return controller.allChats.isEmpty
                    ? Column(
                        children: [
                          SafeArea(
                            bottom: false,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _removeOverlay();
                                startNewChat();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
                                height: 60,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[900]?.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text("Start New Chat", style: TextStyle(fontSize: 20, fontFamily: mainFont, color: Colors.blueGrey)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: size.width * .6,
                                    child: Opacity(
                                      opacity: .5,
                                      child: Image.asset(
                                        'assets/icons/chatPic.png',
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Start new chat...",
                                    style: TextStyle(fontSize: size.width * .05),
                                  ),
                                  const SizedBox(height: 120),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    : SlidableAutoCloseBehavior(
                        child: SafeArea(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: controller.allChats.length,
                            itemBuilder: (context, index) {
                              if (controller.allChats[index].messages.isEmpty) return const SizedBox();
                              return Column(
                                children: [
                                  if (index == 0)
                                    SafeArea(
                                      bottom: false,
                                      child: CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          startNewChat();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(10),
                                          height: 60,
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[900]?.withOpacity(.2),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text("Start New Chat", style: TextStyle(fontSize: 20, fontFamily: mainFont, color: Colors.blueGrey)),
                                        ),
                                      ),
                                    ),
                                  Slidable(
                                    startActionPane: ActionPane(
                                      extentRatio: .25,
                                      motion: const ScrollMotion(),
                                      children: [
                                        // A SlidableAction can have an icon and/or a label.
                                        SlidableAction(
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(15)),
                                          autoClose: true,
                                          onPressed: (x) async {
                                            bool isAccepted = false;

                                            await MyDialog.warningDialog(
                                              context,
                                              title: "Delete chat",
                                              body: "Are you sure to delete this chat?",
                                              onConfirm: () {
                                                isAccepted = true;
                                              },
                                              showOnCancel: true,
                                              confirmText: 'Delete',
                                              dialogColor: mainColor,
                                              confirmTextColor: Colors.white,
                                            );

                                            if (isAccepted) {
                                              controller.allChats.removeAt(index);
                                              controller.refreshChats();
                                            }
                                          },
                                          backgroundColor: mainColor.withOpacity(.5),
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ],
                                    ),
                                    child: GestureDetector(
                                      onLongPressStart: (details) {
                                        _showOverlay(context, controller.allChats[index]);
                                      },
                                      onLongPressEnd: (details) {
                                        _removeOverlay();
                                      },
                                      child: ListTile(
                                        leading: const Icon(Icons.chat_bubble_outline_rounded),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                controller.allChats[index].title.trim().isEmpty ? "NO TITLE" : controller.allChats[index].title.trim(),
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  overflow: TextOverflow.ellipsis,
                                                  fontFamily: mainFont,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              controller.allChats[index].getLastMessageDate(),
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: Colors.grey[300]?.withOpacity(.5),
                                                fontSize: 13,
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: mainFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              controller.allChats[index].messages.first.message.split('\n').join(' ').trim().replaceAll(RegExp(r'[*_~`#">+\-!\[\]()]'), ''),
                                              maxLines: 2,
                                              style: const TextStyle(color: Colors.grey),
                                              textDirection: getTextDirection(controller.allChats[index].messages.first.message.split('\n').join(' ').trim()),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              textBaseline: TextBaseline.alphabetic,
                                              verticalDirection: VerticalDirection.up,
                                              textDirection: TextDirection.ltr,
                                              children: [
                                                const Center(child: Icon(Icons.blur_circular_rounded, size: 15)),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      style: TextStyle(fontFamily: mainFont, color: Colors.white54),
                                                      children: [
                                                        const TextSpan(text: "Number of Ai Responses:  "),
                                                        TextSpan(
                                                          text: controller.allChats[index].getNumberOfResponse().toString(),
                                                          style: TextStyle(fontWeight: FontWeight.bold, color: mainColor.withOpacity(.45)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  controller.allChats[index].modelUsed == geminiModuleName ? "Gemini pro" : "chatGPT",
                                                  style: TextStyle(
                                                    color: controller.allChats[index].modelUsed == geminiModuleName ? mainColor.withOpacity(.5): Colors.yellowAccent.withOpacity(.5)
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          _removeOverlay();
                                          await Get.to(() => ChatScreen(chat: controller.allChats[index]));
                                          setState(() {});
                                        },
                                        hoverColor: Colors.black26,
                                        focusColor: Colors.black26,
                                        splashColor: Colors.black26,
                                      ),
                                    ),
                                  ),
                                  if (index == controller.allChats.length - 1) const SafeArea(top: false, child: SizedBox()),
                                ],
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return const Divider(
                                height: 0,
                                color: Colors.white10,
                              );
                            },
                          ),
                        ),
                      );
              }),
        ],
      ),
    );
  }

// Declare AnimationController outside of the function so it can be accessed by both functions
  AnimationController? _controller;

  void _showOverlay(BuildContext context, ChatClass chat) {
    // Initialize the animation controller with 300ms duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: Navigator.of(context),
    );

    // Define a Tween to animate the scale from 0.0 to 0.8
    final Animation<double> scaleAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOutBack));

    _controller!.forward(); // Start the opening animation

    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: Colors.black38,
        child: Center(
          child: AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white10,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: ChatScreen(chat: chat),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Insert the overlay entry into the Overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null && _controller != null) {
      // Reverse the animation for closing
      _controller!.reverse().then((_) {
        // Remove the overlay after the animation completes
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }
}
