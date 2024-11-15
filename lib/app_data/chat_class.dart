import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'constants.dart';
import 'message_class.dart';

class ChatClass {
  List<Message> messages;
  String title;
  DateTime startChatTime;
  DateTime lastChatTime;
  String id;

  ChatClass({
    required this.messages,
    required this.title,
    required this.startChatTime,
    required this.lastChatTime,
    required this.id,
  });

  // Named constructor for converting JSON to ChatClass
  factory ChatClass.fromJson(Map<String, dynamic> json) {
    return ChatClass(
      messages: (json['messages'] as List<dynamic>).map((message) => Message.fromJson(message)).toList(),
      title: json['title'],
      startChatTime: DateTime.parse(json['startChatTime']),
      lastChatTime: DateTime.parse(json['lastChatTime']),
      id: json['id'],
    );
  }

  // Method for converting ChatClass to JSON
  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'title': title,
      'startChatTime': startChatTime.toIso8601String(),
      'lastChatTime': lastChatTime.toIso8601String(),
      'id': id,
    };
  }

  int getNumberOfResponse() {
    int result = 0;
    for (Message message in messages) {
      if (message.sender == 1) {
        result++;
      }
    }
    return result;
  }

  void addMessage(String message, int sender) {
    messages.add(Message(
      message: message,
      sender: sender,
      timeSent: DateTime.now(),
      id: generateId(),
    ));
    messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
  }

  Future<void> sendMessage(String message) async {
    try {
      GenerativeModel model = GenerativeModel(model: geminiModel, apiKey: apiKey);
      // List<Content> content = [Content.text(message)];
      // GenerateContentResponse response = await model.generateContent(content);

      List<Content> content = [
        ...[for (Message message in messages) Content.text(message.message)].reversed,
        Content.text(message),
      ];
      GenerateContentResponse response = await model.generateContent(
        content,

      );

      addMessage(response.text ?? "No response", 1);
      messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));

      if (title.trim().isEmpty) await generateChatTitle();
    } catch (e, f) {
      if (kDebugMode) {
        print("============== Error ==============");
        print(e);
        print(f);
      }
      if (e.toString() == "GenerativeAIException: Candidate was blocked due to safety") {
        addMessage("Replay Blocked due to safety content", 1);
      } else {
        // addMessage("Error has happened", 1);
        addMessage(e.toString(), 1);
      }
    }
  }

  Future<void> generateChatTitle() async {
    GenerativeModel model = GenerativeModel(model: geminiModel, apiKey: apiKey);
    // List<Content> content = [Content.text(message)];
    // GenerateContentResponse response = await model.generateContent(content);

    String message =
        """Give me a title for this chat depending on this rules:
- The title should be in the same language as the chat، please if the chat is Arabic the title you send should be Arabic, and if the chat is english so the title should be English, and so on.
- Give the answer with title only with no quotes or any other symbol, because your response will be the title directly.
- Make the title as short as possible and meaningful.
""";

    // String message = "Based on the following conversation, generate a concise and descriptive title in the same language as the chat";
    // String message = "Give a title for this chat as the same language as the chat, answer is without any symbols.";

    List<Content> content = [
      Content.text(message),
      ...[for (Message message in messages) Content.text(message.message)].reversed,

    ];
    GenerateContentResponse response = await model.generateContent(content);

    // print("===========================");
    // print(response.text);
    title = response.text.toString().trim();
    // print("===========================");
  }

  String getLastMessageDate() {
    DateTime now = DateTime.now();
    if(lastChatTime.year == now.year && lastChatTime.month == now.month && lastChatTime.day == now.day){
      return "${(lastChatTime.hour ).toString().padLeft(2, '0')}:${lastChatTime.minute.toString().padLeft(2, '0')} ${lastChatTime.hour > 12? "PM" : "AM"}";
    } else if(lastChatTime.year == now.year){
      return "${lastChatTime.day.toString().padLeft(2, '0')}/${lastChatTime.month.toString().padLeft(2, '0')}";
    } else {
      return "${lastChatTime.day.toString().padLeft(2, '0')}/${lastChatTime.month.toString().padLeft(2, '0')}/${lastChatTime.year}";
    }
    // return "${lastChatTime.hour.toString().padLeft(2, '0')}:${lastChatTime.minute.toString().padLeft(2, '0')}";
    if (DateTime.now().year != lastChatTime.year) return lastChatTime.year.toString();
    return "${lastChatTime.month}/${lastChatTime.day}";
  }



  Future<void> generateImage(String message) async {
    try {
      GenerativeModel model = GenerativeModel(model: 'imagen-3.0-generate-001', apiKey: apiKey);

      // Generate an image
      const prompt = 'A serene landscape with mountains and a river at sunset';
      final response = await model.generateContent([Content.text(prompt)]);

      // Access the generated image URL
      final imageUrl = response.text.toString();
      print('Generated Image URL: $imageUrl');

      return;

      List<Content> content = [
        ...[for (Message message in messages) Content.text(message.message)].reversed,
        Content.text(message),
      ];
      // GenerateContentResponse response = await model.generateContent(
      //   content,
      // );
      print("----===============-------");
      print("----===============-------");
      print(response.text);
      print("----===============-------");
      print("----===============-------");
      // final response = await GenerativeAi.generateImage(
      //   prompt: prompt,
      //   model: 'imagen-3.0-generate-001', // Specify the model version
      //   numberOfImages: 1,
      //   aspectRatio: '1:1',
      // );

      // addMessage(response.text ?? "No response", 1);
      // messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
      //
      // if (title.trim().isEmpty) await generateChatTitle();
    } catch (e, f) {
      if (kDebugMode) {
        print("============== Error ==============");
        print(e);
        print(f);
      }
      if (e.toString() == "GenerativeAIException: Candidate was blocked due to safety") {
        addMessage("Replay Blocked due to safety content", 1);
      } else {
        // addMessage("Error has happened", 1);
        addMessage(e.toString(), 1);
      }
    }
  }
}
