import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_ai_chat/message_class.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends GetxController {
  List<Message> messages = [];

  Future<void> sendMessage(String message) async {
    // Access your API key as an environment variable (see "Set up your API key" above)
    String apiKey = 'AIzaSyAcSn_1H7O9nrNewYKxqAlibywvb7o-T1o';
    try {

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      List<Content> content = [];
      for(Message message in messages){
        content.add(Content.text(message.message));
      }
      final response = await model.generateContent(content);


      // // For text-only input, use the gemini-pro model
      // final model = GenerativeModel(
      //     model: 'gemini-pro',
      //     apiKey: apiKey,
      //     generationConfig: GenerationConfig(maxOutputTokens: 100));
      // // Initialize the chat
      //
      //
      // // adding all the AI replays to to the list
      // List<Part>? modelReplays = [];
      // for (int i = 0; i < messages.length; i++) {
      //   if (messages[i].sender == 1) {
      //     modelReplays.add(
      //       TextPart(messages[i].message),
      //     );
      //   }
      // }
      //
      // final chat = model.startChat(
      //   history: [
      //     // Content.text(message),  // current user message
      //     Content.model(modelReplays),  // all AI replays
      //   ],
      // );
      // Content content = Content.text(message);
      // GenerateContentResponse response = await chat.sendMessage(content);
      // print(response.text);

      addMessage(response.text!, 1);
      saveChat();
    } catch (e) {
      print(e);
      addMessage(e.toString(), 1);
    }
  }

  String removeStars(String text) {
    return text.replaceAll(RegExp(r'[*]'), '');
  }

  void addMessage(String message, int sender) {
    messages.add(Message(message: removeStars(message), sender: sender));
    // update();
  }

  void saveChat() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    List<String> temp = [];
    for (Message message in messages) {
      temp.add(jsonEncode(message));
    }
    pref.setStringList("chat", temp);
  }

  Future<void> loadChat() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> temp = pref.getStringList('chat') ?? [];
    for (String message in temp) {
      Map<String, dynamic> data = jsonDecode(message);
      messages.add(Message(message: data['message'], sender: data['sender']));
    }
    update();
  }
}
