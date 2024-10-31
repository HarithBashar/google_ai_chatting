import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_ai_chat/app_data/message_class.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AppData extends GetxController {
  // Access your API key as an environment variable (see "Set up your API key" above)
  // late String apiKey;
  String apiKey = 'AIzaSyDNQVEviyVqvv989GYvnG5bDJjFNAXTmLE';

  List<Message> messages = [];

  Future<void> sendMessage(String message) async {
    try {
      GenerativeModel model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
      // List<Content> content = [Content.text(message)];
      // GenerateContentResponse response = await model.generateContent(content);

      List<Content> content = [
        ...[for (Message message in messages) Content.text(message.message)].reversed,
        Content.text(message),
      ];
      GenerateContentResponse response = await model.generateContent(content);
      // FirebaseFirestore.instance.collection('messages').add({
      //   "chatNumber": content.length,
      //   "personMessage": message,
      //   "aiResponse": response.text,
      // });
      // ---------------------------------------------------------------

      addMessage(response.text ?? "No response", 1);
      messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
      saveChat();
    } catch (e, f) {
      if (kDebugMode) {
        print("============== Error ==============");
        print(e);
        print(f);
      }
      if (e == "GenerativeAIException: Candidate was blocked due to safety") {
        addMessage("Replay Blocked due to safety content", 1);
      } else {
        addMessage("Error has happened", 1);
      }
    }
  }

  String removeStars(String text) {
    return text.replaceAll(RegExp(r'[*]'), '');
  }

  void addMessage(String message, int sender) {
    messages.add(Message(message: removeStars(message), sender: sender, timeSent: DateTime.now()));
    messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    update();
  }

  void saveChat() async {
    messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    GetStorage().write("chat", messages);
    print("=======================");
    print("=======================");
    print(GetStorage().read('chat'));
    print("=======================");
    print("=======================");
  }

  Future<void> loadChat() async {
    messages.clear();

    var storedMessages = GetStorage().read('chat');

    if (storedMessages != null && storedMessages is List) {
      messages = storedMessages
          .map((messageJson) => Message.fromJson(Map<String, dynamic>.from(messageJson)))
          .toList();
    }
    messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));

    update();
  }


  Future<void> loadChat2() async {
    messages.clear();
    // List<String> temp = box.read('chat') ?? [];
    print("=======================");
    print("=======================");
    print(GetStorage().read('chat'));
    print("=======================");
    print("=======================");
    messages = GetStorage().read('chat');

    // for (String message in temp) {
    //   Map<String, dynamic> data = jsonDecode(message);
    //   messages.add(Message(message: data['message'], sender: data['sender'], timeSent: DateTime.parse(data['timeSent'])));
    // }
    messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    update();
  }
}
