import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'message_class.dart';

class ChatClass {
  List<Message> messages;
  String title;
  DateTime startChatTime;
  DateTime lastChatTime;
  String id;
  String modelUsed;

  ChatClass({
    required this.messages,
    required this.title,
    required this.startChatTime,
    required this.lastChatTime,
    required this.id,
    required this.modelUsed,
  });

  // Named constructor for converting JSON to ChatClass
  factory ChatClass.fromJson(Map<String, dynamic> json) {
    return ChatClass(
      messages: (json['messages'] as List<dynamic>).map((message) => Message.fromJson(message)).toList(),
      title: json['title'],
      startChatTime: DateTime.parse(json['startChatTime']),
      lastChatTime: DateTime.parse(json['lastChatTime']),
      id: json['id'],
      modelUsed: json['modelUsed'] ?? geminiModuleName,
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
      'modelUsed': modelUsed,
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
      modelName: modelUsed,
    ));
    messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));
  }

  Future<void> sendToGemini(String message) async {
    const int maxRetries = 3; // Maximum retry attempts
    const int initialDelay = 2; // Initial delay in seconds
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        // Initialize the GenerativeModel
        GenerativeModel model = GenerativeModel(model: geminiModule, apiKey: geminiKey);

        // Prepare the content for the API call
        List<Content> content = [
          ...[for (Message message in messages) Content.text(message.message)].reversed,
          Content.text(message),
        ];

        // Call the Gemini API
        GenerateContentResponse response = await model.generateContent(content);

        // Process the response
        addMessage(response.text ?? "No response", 1);
        messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));

        // Optionally generate a chat title
        await generateChatTitle();

        return; // Exit the function on success
      } catch (e, f) {
        if (kDebugMode) {
          print("============== Error ==============");
          print(e);
          print(f);
        }

        // Handle specific errors
        if (e.toString().contains("GenerativeAIException: Candidate was blocked due to safety")) {
          addMessage("Reply blocked due to safety content", 1);
          return;
        } else if (e.toString().contains("503")) {
          attempt++;
          int delay = initialDelay * (1 << (attempt - 1)); // Exponential backoff
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: delay));
          } else {
            addMessage("The server is overloaded. Please try again later.", 1);
          }
        } else {
          addMessage("An unexpected error occurred: $e", 1);
          return;
        }
      }
    }
  }

  Future<void> sendToGeminiOld(String message) async {
    try {
      GenerativeModel model = GenerativeModel(model: geminiModule, apiKey: geminiKey);
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

      // if (title.trim().isEmpty || title.trim().split(' ').length >= 10)
      await generateChatTitle();
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
    try {
      GenerativeModel model = GenerativeModel(model: geminiModule, apiKey: geminiKey);

      String message = """Based on the following conversation, craft an appropriate title for it, following these guidelines:

1. The title should be in the same language as the conversation. If the conversation is in English, the title should be in English; if it’s in Arabic, the title should be in Arabic, and so on for other languages.
2. Respond only with the title of the conversation—no symbols, markdown, or any additional text. Only the title.
3. Make the title as concise as possible while ensuring it has a clear meaning.
4. Answer strictly based on the provided information without requesting any additional input.
5. The title should not be more than 9 words.""";

      List<Content> content = [
        Content.text(message),
        ...[for (Message message in messages) Content.text(message.message)],
      ];
      GenerateContentResponse response = await model.generateContent(content);

      title = response.text.toString().trim();
    } catch (_) {}
  }

  String getLastMessageDate() {
    DateTime now = DateTime.now();
    if (lastChatTime.year == now.year && lastChatTime.month == now.month && lastChatTime.day == now.day) {
      return "${(lastChatTime.hour).toString().padLeft(2, '0')}:${lastChatTime.minute.toString().padLeft(2, '0')} ${lastChatTime.hour > 12 ? "PM" : "AM"}";
    } else if (lastChatTime.year == now.year) {
      return "${lastChatTime.day.toString().padLeft(2, '0')}/${lastChatTime.month.toString().padLeft(2, '0')}";
    } else {
      return "${lastChatTime.day.toString().padLeft(2, '0')}/${lastChatTime.month.toString().padLeft(2, '0')}/${lastChatTime.year}";
    }
  }

  Future<void> sendToChatGPT(String prompt) async {
    if (kDebugMode) print("Send to chatGPT...");
    List<Map<String, String>> messages = [];
    for (int i = this.messages.length - 1; i >= 0; i--) {
      messages.add({
        'role': this.messages[i].sender == 0 ? "user" : 'system',
        'content': this.messages[i].message.toString(),
      });
    }
    messages.add({'role': "user", "content": prompt});

    try {
      var response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $chatGPTKey',
        },
        body: jsonEncode({
          'model': chatGPTModule,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        // Decode response body as UTF-8
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        String? gptResponse = data['choices'][0]['message']['content'];
        if (kDebugMode) {
          log("gptResponse: $gptResponse");
        }
        addMessage(gptResponse ?? "No response", 1);
        this.messages.sort((a, b) => b.timeSent.compareTo(a.timeSent));

        if (title.trim().isEmpty || title.trim().split(' ').length >= 10) generateChatTitle();
      } else {
        log("Error: ${response.body}");
        addMessage('No Internet connection', 1);
      }
    } catch (e, f) {
      if (kDebugMode) {
        print(e);
        print('==================');
        print(f);
      }
      addMessage(e.toString(), 1);
    }
  }
}
