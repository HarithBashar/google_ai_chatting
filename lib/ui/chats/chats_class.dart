import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_ai_chat/app_data/chat_class.dart';

class ChatsClass extends GetxController {
  List<ChatClass> allChats = [];

  Future<void> getAllChats() async {
    GetStorage box = GetStorage();
    // allChats = box.read('allChats').map((item) => item as ChatClass).toList();
    for (int i = 0; i < box.read('allChats').length; i++) {
      allChats.add(ChatClass.fromJson(box.read('allChats')[i]));
    }
    // print(ChatClass.fromJson(box.read('allChats')[0]));
    // newest first
    allChats.sort((a, b) => b.lastChatTime.compareTo(a.lastChatTime));
    update();
  }

  Future<void> saveAllChats() async {
    GetStorage box = GetStorage();
    box.write('allChats', allChats);
    update();
  }

  Future<void> refreshChats() async {
    allChats.sort((a, b) => b.lastChatTime.compareTo(a.lastChatTime));
    await saveAllChats();
  }

  Future<void> deleteEmptyChats() async {
    List<String> emptyChatsIds = [];
    for (ChatClass chat in allChats) {
      if (chat.messages.isEmpty) {
        emptyChatsIds.add(chat.id);
      }
    }
    for (String chatId in emptyChatsIds) {
      allChats.removeWhere((chat) => chat.id == chatId);
    }
    update();
  }
}
